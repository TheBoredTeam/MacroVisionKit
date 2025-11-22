//
//  FullScreenMonitor.swift
//  MacroVisionKit
//
//  Created by Alexander on 2025-11-21.
//

import Cocoa

// MARK: - FullScreenMonitor

public actor FullScreenMonitor {
    public static let shared = FullScreenMonitor()
    
    // MARK: - Public Types
    
    public struct SpaceInfo: Equatable, Sendable {
        public let runningApps: [String]
        public let screenUUID: String?
        
        public var debugDescription: String {
            let screenName = screenUUID.map { String($0.prefix(8)) } ?? "Unknown"
            let apps = runningApps.isEmpty ? "Unknown" : runningApps.joined(separator: ", ")
            return "Screen: \(screenName) - Full Screen: \(apps)"
        }
        
        public static func == (lhs: SpaceInfo, rhs: SpaceInfo) -> Bool {
            return lhs.runningApps == rhs.runningApps &&
                   lhs.screenUUID == rhs.screenUUID
        }
    }
    
    
    // MARK: - Properties
    
    private var fullscreenSpaces: [SpaceInfo] = []
    private var spaceChangesContinuation: AsyncStream<[SpaceInfo]>.Continuation?
    
    // Observer tokens are nonisolated(unsafe) since they're only accessed from nonisolated init/deinit
    // This is safe because init and deinit are synchronous and don't overlap with actor execution
    private nonisolated(unsafe) var observerTokens: [NSObjectProtocol] = []
    
    // MARK: - Initialization
    
    private init() {
        fullscreenSpaces = Self.detectSpaces()
        setupObservers()
    }
    
    deinit {
        spaceChangesContinuation?.finish()
        removeObservers()
    }
    
    // MARK: - Private Methods
    
    private nonisolated func setupObservers() {
        let center = NSWorkspace.shared.notificationCenter
        
        let spaceChangeToken = center.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { [weak self] in
                await self?.updateSpaceInformation()
            }
        }
        
        let screenChangeToken = center.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { [weak self] in
                await self?.updateSpaceInformation()
            }
        }
        
        observerTokens = [spaceChangeToken, screenChangeToken]
    }
    
    private nonisolated func removeObservers() {
        let center = NSWorkspace.shared.notificationCenter
        for token in observerTokens {
            center.removeObserver(token)
        }
        observerTokens.removeAll()
    }
    
    private func updateSpaceInformation() {
        let newSpaces = Self.detectSpaces()
        let newFullscreenSpaces = newSpaces
        
        if fullscreenSpaces != newFullscreenSpaces {
            fullscreenSpaces = newFullscreenSpaces
            spaceChangesContinuation?.yield(newFullscreenSpaces)
        }
    }

    private nonisolated static func detectSpaces() -> [SpaceInfo] {
        guard let displaySpaces = CGSCopyManagedDisplaySpaces(_CGSMainConnectionID()) as? [NSDictionary] else {
            return []
        }
        
        var newSpaces: [SpaceInfo] = []
        
        for displayDict in displaySpaces {
            guard let currentSpaceDict = displayDict["Current Space"] as? [String: Any],
                  let spacesList = displayDict["Spaces"] as? [[String: Any]],
                  let displayID = displayDict["Display Identifier"] as? String else {
                continue
            }
            
            let activeSpaceID = currentSpaceDict["ManagedSpaceID"] as? Int ?? -1
            
            // Only look for the active space in the list
            guard let activeSpace = spacesList.first(where: { ($0["ManagedSpaceID"] as? Int) == activeSpaceID }) else {
                continue
            }
            
            let tileLayoutManager = activeSpace["TileLayoutManager"] as? [String: Any]
            let isFullScreen = tileLayoutManager != nil
            
            if isFullScreen {
                var runningApps: [String] = []
                
                // First, try to get the primary app from the pid field
                if let pidVal = activeSpace["pid"] as? Int32,
                   let app = NSRunningApplication(processIdentifier: pidVal),
                   let bundleID = app.bundleIdentifier {
                    runningApps.append(bundleID)
                }
                
                // For split screen, check the TileLayoutManager for additional apps
                if let tileManager = tileLayoutManager,
                   let tileWindows = tileManager["TileSpaces"] as? [[String: Any]] {
                    for tile in tileWindows {
                        if let windowPID = tile["pid"] as? Int32,
                           let app = NSRunningApplication(processIdentifier: windowPID),
                           let bundleID = app.bundleIdentifier,
                           !runningApps.contains(bundleID) {
                            runningApps.append(bundleID)
                        }
                    }
                }
                
                let space = SpaceInfo(
                    runningApps: runningApps,
                    screenUUID: displayID
                )
                
                newSpaces.append(space)
            }
        }
        
        return newSpaces
    }
    
    // MARK: - Public API
    
    /// Returns the current fullscreen spaces
    public func detectFullscreenApps(debug: Bool = false) -> [SpaceInfo] {
        return fullscreenSpaces
    }
    
    /// Returns an async stream that emits changes to fullscreen spaces
    /// - Returns: AsyncStream that yields [SpaceInfo] whenever fullscreen spaces change
    public func spaceChanges() -> AsyncStream<[SpaceInfo]> {
        AsyncStream { continuation in
            self.spaceChangesContinuation = continuation
            
            // Immediately yield current state
            continuation.yield(self.fullscreenSpaces)
            
            continuation.onTermination = { @Sendable _ in
                Task { [weak self] in
                    await self?.clearContinuation()
                }
            }
        }
    }
    
    private func clearContinuation() {
        spaceChangesContinuation = nil
    }
    
    /// Resolves the NSScreen for a given SpaceInfo
    /// - Parameter space: The SpaceInfo to resolve the screen for
    /// - Returns: The NSScreen if found, nil otherwise
    @MainActor
    public func screen(for space: SpaceInfo) -> NSScreen? {
        guard let uuid = space.screenUUID else { return nil }
        
        return NSScreen.screens.first { screen in
            guard let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else { return false }
            let id = CGDirectDisplayID(number.uint32Value)
            guard let screenUUID = CGDisplayCreateUUIDFromDisplayID(id) else { return false }
            let uuidString = CFUUIDCreateString(nil, screenUUID.takeRetainedValue()) as String
            return uuidString == uuid
        }
    }
}

// MARK: - Private CGS API Definitions

private typealias CGSConnectionID = Int32
@_silgen_name("CGSMainConnectionID") private func _CGSMainConnectionID() -> CGSConnectionID
@_silgen_name("CGSCopyManagedDisplaySpaces") private func CGSCopyManagedDisplaySpaces(_ cid: CGSConnectionID) -> CFArray
