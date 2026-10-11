// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "Blog",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/s4cha/Squeal", from: "0.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "Blog",
            dependencies: [
                .product(name: "Squeal", package: "Squeal"),
            ]
        ),
    ]
)
