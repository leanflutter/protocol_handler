// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "protocol_handler_plus_macos",
    platforms: [
        .macOS("12.0")
    ],
    products: [
        .library(name: "protocol-handler-plus-macos", targets: ["protocol_handler_plus_macos"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "protocol_handler_plus_macos",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Classes"
        )
    ]
)
