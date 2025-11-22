// swift-tools-version: 6.1
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
    ]
) 