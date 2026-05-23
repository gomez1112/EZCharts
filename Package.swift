// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "EZCharts",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "EZCharts",
            targets: ["EZCharts"]
        ),
        .library(
            name: "EZCharts3D",
            targets: ["EZCharts3D"]
        )
    ],
    targets: [
        .target(
            name: "EZCharts"
        ),
        .target(
            name: "EZCharts3D",
            dependencies: ["EZCharts"]
        ),
        .testTarget(
            name: "EZChartsTests",
            dependencies: ["EZCharts"]
        )
    ]
)
