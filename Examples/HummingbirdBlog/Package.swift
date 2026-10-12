// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "HummingbirdBlog",
    platforms: [.macOS(.v14)],
    dependencies: [
        // In your own app: .package(url: "https://github.com/s4cha/Squeal", from: "0.2.0")
        .package(path: "../.."),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.25.0"),
        .package(url: "https://github.com/vapor/postgres-nio", from: "1.21.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Squeal", package: "Squeal"),
                .product(name: "SquealPostgresNIO", package: "Squeal"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "PostgresNIO", package: "postgres-nio"),
            ]
        ),
    ]
)
