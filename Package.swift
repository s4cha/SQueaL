// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Squeal",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "Squeal",
            targets: ["Squeal"]),
    ],
    targets: [
        .target(
            name: "Squeal"),
        .testTarget(
            name: "SquealTests",
            dependencies: ["Squeal"]),
    ]
)
