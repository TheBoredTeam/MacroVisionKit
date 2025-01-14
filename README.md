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
    .package(url: "https://github.com/theboringhumane/MacroVisionKit.git", from: "1.0.0")
]
```

## Usage

### Basic Implementation

```swift
import MacroVisionKit

// Initialize the detector
let detector = MacroVisionKit.shared
let fullscreenApps = detector.detectFullscreenApps()

// Process detection results
fullscreenApps.forEach { appInfo in
    print(appInfo.debugDescription)
}
```

### Advanced Configuration

```swift
// Configure detection parameters
var config = MacroVisionKit.Configuration()
config.sizeTolerance = 0.15 // 15% tolerance threshold
config.includeSystemApps = true

// Apply configuration
MacroVisionKit.shared.configuration = config
```

### Diagnostic Mode

```swift
// Enable diagnostic output for detailed analysis
let fullscreenApps = detector.detectFullscreenApps(debug: true)
```

## Technical Requirements

- macOS 10.15 or later
- Swift 5.0 or later

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Created by [github.com/theboringhumane](https://github.com/theboringhumane)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 