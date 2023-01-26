// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let pckage = Package(
    name: "ScrollViewEvents",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "ScrollViewEvents",
            targets: ["ScrollViewEvents"]),
    ],
    targets: [
        .target(
            name: "ScrollViewEvents",
            dependencies: []),
    ]
)
