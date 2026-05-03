# EZCharts

`EZCharts` is a small Swift package for adding reusable animation timing to Swift Charts.

```swift
EZAnimatedChart { progress in
    BarMark(
        x: .value("Month", month),
        y: .value("Revenue", value * progress)
    )
}
```

Use `EZChartProgress.staggered(index:count:progress:)` when each mark should grow in sequence, and `EZAnimatedChart(reveal: .horizontal)` when a line or area chart should draw across the plot.

## Demo App

The starter iOS app lives in `Examples/EZChartsDemo` and imports this package through a local Swift package reference.

## Swift Package Manager

After this repository is hosted on GitHub, add it to an app in Xcode with:

```text
https://github.com/gomez1112/EZCharts.git
```

Or add it to a `Package.swift` manifest while the package is evolving:

```swift
.package(url: "https://github.com/gomez1112/EZCharts.git", branch: "main")
```

Build and launch with:

```sh
./scripts/build_and_launch.sh
```

You can override the simulator when needed:

```sh
SIMULATOR_NAME="iPad Pro 11-inch (M4)" ./scripts/build_and_launch.sh
```
