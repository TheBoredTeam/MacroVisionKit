# MacroVisionKit

A sophisticated macOS framework for real-time detection and analysis of application window states, specifically focused on identifying applications operating in full-screen or maximized viewport configurations.

## Features

- 🔬 High-precision window state detection
- ⚙️ Configurable detection parameters
- 🎯 Advanced process filtering capabilities
- 📊 Comprehensive application metrics
- 🪟 Real-time window analysis

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/TheBoredTeam/MacroVisionKit.git", from: "0.2.0")
]
```

## Usage

### Basic Implementation

```swift
import MacroVisionKit

// Initialize the monitor
let monitor = FullScreenMonitor.shared

// Get current Full Screen apps
let fullScreenApps = monitor.detectFullscreenApps()

// Process detection results
fullScreenApps.forEach { spaceInfo in
    print(spaceInfo.debugDescription)
}
```

### Real-time Updates

Use the `spaceChanges()` method to get an asynchronous stream of fullscreen space updates:

```swift
import MacroVisionKit

// Get the stream of space changes
let monitor = FullScreenMonitor.shared
let stream = await monitor.spaceChanges()

// Process updates asynchronously
for await fullScreenSpaces in stream {
    print("Fullscreen spaces updated: \(fullScreenSpaces.count)")
    fullScreenSpaces.forEach { spaceInfo in
        print(spaceInfo.debugDescription)
    }
}
```

### Testing with the Example

To test the framework, you can run the included example application. First, ensure you have Swift installed on your macOS system.

1. Clone the repository:
   ```bash
   git clone https://github.com/TheBoredTeam/MacroVisionKit.git
   cd MacroVisionKit
   ```

2. Build and run the example:
   ```bash
   swift run FullScreenMonitorExample
   ```

3. The example will start monitoring for fullscreen space changes. Open some applications in fullscreen mode to see the detection in action. Press `Ctrl+C` to exit.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Created by [github.com/theboringhumane](https://github.com/theboringhumane)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 