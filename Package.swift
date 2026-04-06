// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "GGUFCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "GGUFCore", targets: ["GGUFCore"])
    ],
    targets: [
        .target(name: "GGUFCore"),
        .testTarget(name: "GGUFCoreTests", dependencies: ["GGUFCore"])
    ]
)
