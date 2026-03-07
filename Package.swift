// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Squeal",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "Squeal", targets: ["Squeal"]),
    ],
    dependencies: [
      .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0-latest"),
    ],
    targets: [
        .macro(
            name: "SquealMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        
            .target(name: "Squeal", dependencies: ["SquealMacros"]),
        .testTarget(name: "SquealTests", dependencies: ["Squeal"]),
    ]
)
