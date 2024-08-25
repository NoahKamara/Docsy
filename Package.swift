// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Docsy",
    platforms: [.macOS(.v15), .iOS(.v18), .visionOS(.v2)],
    products: [
        .library(
            name: "Docsy",
            targets: ["Docsy"]),
    ],
    dependencies: [
        .package(url: "https://github.com/DoccZz/DocCArchive.git", from: "0.4.1")
    ],
    targets: [
        .target(
            name: "Docsy",
            dependencies: ["DocCArchive"]
        ),
        .testTarget(
            name: "Tests",
            dependencies: ["Docsy"]
        )
    ]
)
