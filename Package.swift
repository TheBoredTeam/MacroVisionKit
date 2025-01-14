// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacroVisionKit",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "MacroVisionKit",
            targets: ["MacroVisionKit"]),
    ],
    targets: [
        .target(
            name: "MacroVisionKit"),
        .testTarget(
            name: "MacroVisionKitTests",
            dependencies: ["MacroVisionKit"]),
    ]
) 