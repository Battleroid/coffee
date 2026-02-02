// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Coffee",
    platforms: [
        .macOS(.v12)
    ],
    targets: [
        .executableTarget(
            name: "Coffee",
            path: "Sources"
        )
    ]
)
