// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Docsy",
    platforms: [.macOS(.v15), .iOS(.v18), .visionOS(.v2)],
    products: [
        .library(
            name: "Docsy",
            targets: ["Docsy"]
        ),
        .library(
            name: "DocsySchema",
            targets: ["DocsySchema"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Docsy",
            dependencies: ["DocsySchema"]
        ),
        .target(name: "DocsySchema", dependencies: ["DocsyCore"]),
        .target(name: "DocsyCore"),
        .testTarget(
            name: "Tests",
            dependencies: ["Docsy"]
        )
    ]
)
