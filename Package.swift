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
        .library(
            name: "TestResources",
            targets: ["TestResources"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Docsy",
            dependencies: ["DocsySchema"]
        ),
        .target(name: "DocsySchema"),
        .target(
            name: "TestResources",
            path: "Tests/TestResources",
            resources: [
                .copy("Resources/."),
            ]
        ),
//        .testTarget(
//            name: "Tests",
//            dependencies: ["Docsy", "TestResources"],
//            resources: [
//                .copy("Resources/")
//            ]
//        )
        .testTarget(
            name: "SchemaTests",
            dependencies: ["DocsySchema", "TestResources"]
        ),
    ]
)
