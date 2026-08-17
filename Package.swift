// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "EZCharts",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .visionOS(.v1)
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
            name: "EZCharts",
            resources: [.process("Resources")],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: "EZCharts3D",
            dependencies: ["EZCharts"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "EZChartsTests",
            dependencies: ["EZCharts"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
