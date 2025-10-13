// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "cartracker",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "cartracker",
            targets: ["cartracker"]
        ),
    ],
    dependencies: [
        // No external dependencies yet
        // Future: Add dependencies for database, networking, etc.
    ],
    targets: [
        .target(
            name: "cartracker",
            dependencies: [],
            path: "Sources/cartracker",
            resources: [
                .process("Info.plist")
            ]
        ),
        .testTarget(
            name: "cartrackerTests",
            dependencies: ["cartracker"],
            path: "Tests/cartrackerTests"
        ),
    ]
)
