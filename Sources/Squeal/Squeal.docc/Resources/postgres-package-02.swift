// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "Blog",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/s4cha/Squeal", from: "0.2.0"),
        .package(url: "https://github.com/vapor/postgres-nio", from: "1.21.0"),
    ],
    targets: [
        .executableTarget(
            name: "Blog",
            dependencies: [
                .product(name: "Squeal", package: "Squeal"),
                .product(name: "SquealPostgresNIO", package: "Squeal"),
                .product(name: "PostgresNIO", package: "postgres-nio"),
            ]
        ),
    ]
)
