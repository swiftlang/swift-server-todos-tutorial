// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "swift-server-todos",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [
        // Server scaffolding
        .package(url: "https://github.com/vapor/vapor", from: "4.0.0"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle", from: "2.1.0"),
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-vapor", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-configuration", from: "1.2.0"),

        // Telemetry
        .package(url: "https://github.com/apple/swift-log", from: "1.5.2"),
        .package(url: "https://github.com/apple/swift-metrics", from: "2.5.0"),
        .package(url: "https://github.com/apple/swift-distributed-tracing", from: "1.2.0"),
        .package(url: "https://github.com/swift-otel/swift-otel", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-system-metrics", from: "1.2.1"),

        // Database
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftServerTodos",
            dependencies: [
                // Server scaffolding
                .product(name: "Vapor", package: "vapor"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "Configuration", package: "swift-configuration"),

                // Telemetry
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics"),
                .product(name: "Tracing", package: "swift-distributed-tracing"),
                .product(name: "OTel", package: "swift-otel"),
                .product(name: "SystemMetrics", package: "swift-system-metrics"),

                // Database
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        )
    ]
)
