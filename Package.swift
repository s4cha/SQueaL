// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "squeal",
    products: [
        .library(
            name: "squeal",
            targets: ["squeal"]),
    ],
    targets: [
        .target(
            name: "squeal"),
        .testTarget(
            name: "squealTests",
            dependencies: ["squeal"]),
    ]
)
