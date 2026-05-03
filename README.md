# EZCharts

`EZCharts` is a small Swift package that makes Swift Charts animations easier to reuse. It gives you:

- `EZAnimatedChart`, a wrapper around `Chart` that drives an animation progress value from `0` to `1`.
- `EZChartProgress.scaled`, for marks that should grow from zero to their final value.
- `EZChartProgress.staggered`, for bar charts where each mark should animate in sequence.
- `EZChartReveal.horizontal`, for line and area charts that should draw across the plot from left to right.

The package is intentionally light. You still write normal Swift Charts marks, scales, styles, and axes. `EZCharts` only provides the reusable animation timing.

## Requirements

- Swift 5.9+
- iOS 16+
- macOS 13+
- SwiftUI
- Swift Charts

## Installation

In Xcode:

1. Open your app project.
2. Choose `File > Add Package Dependencies`.
3. Paste:

```text
https://github.com/gomez1112/EZCharts.git
```

4. Select version `0.1.0` or newer.
5. Add the `EZCharts` product to your app target.

In `Package.swift`:

```swift
.package(url: "https://github.com/gomez1112/EZCharts.git", from: "0.1.0")
```

Then add `EZCharts` to the target that uses it:

```swift
.target(
    name: "YourApp",
    dependencies: ["EZCharts"]
)
```

## Importing

Use both `Charts` and `EZCharts` in the SwiftUI view that draws charts:

```swift
import Charts
import EZCharts
import SwiftUI
```

## Basic Bar Animation

Use `EZAnimatedChart` instead of `Chart`. The closure gives you a `progress` value that animates from `0` to `1`.

```swift
struct SalesPoint: Identifiable {
    let id = UUID()
    let month: String
    let value: Double
}

let sales = [
    SalesPoint(month: "Jan", value: 34),
    SalesPoint(month: "Feb", value: 42),
    SalesPoint(month: "Mar", value: 58)
]

struct SalesChart: View {
    var body: some View {
        EZAnimatedChart { progress in
            ForEach(sales) { point in
                BarMark(
                    x: .value("Month", point.month),
                    y: .value(
                        "Sales",
                        EZChartProgress.scaled(point.value, progress: progress)
                    )
                )
            }
        }
        .chartYScale(domain: 0...100)
        .frame(height: 280)
    }
}
```

`EZChartProgress.scaled(point.value, progress: progress)` is the key line. When `progress` is `0`, the bar is `0`. When `progress` is `1`, the bar is the real value.

## Staggered Bar Animation

For a nicer entrance, animate each bar with its own timing window:

```swift
struct StaggeredSalesChart: View {
    var body: some View {
        EZAnimatedChart(animation: .snappy) { progress in
            ForEach(Array(sales.enumerated()), id: \.element.id) { index, point in
                let barProgress = EZChartProgress.staggered(
                    index: index,
                    count: sales.count,
                    progress: progress,
                    itemDuration: 0.45
                )

                BarMark(
                    x: .value("Month", point.month),
                    y: .value(
                        "Sales",
                        EZChartProgress.scaled(point.value, progress: barProgress)
                    )
                )
                .foregroundStyle(.blue)
            }
        }
        .chartYScale(domain: 0...100)
        .frame(height: 280)
    }
}
```

`itemDuration` controls how much of the total animation each item receives. Smaller values create a more separated cascade.

## Line Reveal Animation

For line and area charts, keep your real values and use `reveal: .horizontal`. This masks the plot area from left to right.

```swift
struct GrowthPoint: Identifiable {
    let id = UUID()
    let week: String
    let value: Double
}

let growth = [
    GrowthPoint(week: "W1", value: 12),
    GrowthPoint(week: "W2", value: 18),
    GrowthPoint(week: "W3", value: 26),
    GrowthPoint(week: "W4", value: 31),
    GrowthPoint(week: "W5", value: 45)
]

struct GrowthChart: View {
    var body: some View {
        EZAnimatedChart(
            animation: EZChartAnimation(duration: 1.1, curve: .easeInOut),
            reveal: .horizontal
        ) { _ in
            ForEach(growth) { point in
                AreaMark(
                    x: .value("Week", point.week),
                    y: .value("Adoption", point.value)
                )
                .foregroundStyle(.cyan.opacity(0.18))

                LineMark(
                    x: .value("Week", point.week),
                    y: .value("Adoption", point.value)
                )
                .foregroundStyle(.cyan)
                .lineStyle(
                    StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )

                PointMark(
                    x: .value("Week", point.week),
                    y: .value("Adoption", point.value)
                )
                .foregroundStyle(.cyan)
            }
        }
        .chartYScale(domain: 0...60)
        .frame(height: 280)
    }
}
```

Notice that the closure ignores `progress` with `{ _ in ... }`. For horizontal reveal animations, the data stays at full value and the chart plot is clipped until the animation finishes.

## Replaying an Animation

Pass a `replayToken` and change it whenever you want the chart to restart.

```swift
struct ReplayableChart: View {
    @State private var replayToken = UUID()

    var body: some View {
        VStack {
            EZAnimatedChart(
                animation: .snappy,
                replayToken: replayToken
            ) { progress in
                ForEach(sales) { point in
                    BarMark(
                        x: .value("Month", point.month),
                        y: .value(
                            "Sales",
                            EZChartProgress.scaled(point.value, progress: progress)
                        )
                    )
                }
            }
            .chartYScale(domain: 0...100)
            .frame(height: 280)

            Button {
                replayToken = UUID()
            } label: {
                Label("Replay", systemImage: "arrow.clockwise")
            }
        }
    }
}
```

Any `Hashable` value can be used as the token. A new `UUID()` is the simplest option.

## Animation Presets

`EZChartAnimation` includes a few presets:

```swift
EZAnimatedChart(animation: .smooth) { progress in
    // Marks
}

EZAnimatedChart(animation: .quick) { progress in
    // Marks
}

EZAnimatedChart(animation: .snappy) { progress in
    // Marks
}
```

You can also create your own:

```swift
EZAnimatedChart(
    animation: EZChartAnimation(
        duration: 1.2,
        delay: 0.15,
        curve: .easeInOut
    )
) { progress in
    // Marks
}
```

Supported curves:

- `.easeInOut`
- `.easeOut`
- `.linear`
- `.spring(response:dampingFraction:)`

## API Reference

### `EZAnimatedChart`

```swift
EZAnimatedChart(
    animation: EZChartAnimation = .smooth,
    reveal: EZChartReveal = .none,
    replayToken: AnyHashable? = nil
) { progress in
    // ChartContent
}
```

Use this wherever you would normally use `Chart`. The closure must return Swift Charts content such as `BarMark`, `LineMark`, `AreaMark`, `PointMark`, or combinations of those marks.

### `EZChartProgress.scaled`

```swift
EZChartProgress.scaled(value, progress: progress)
```

Returns `value * progress`, with progress clamped between `0` and `1`.

### `EZChartProgress.staggered`

```swift
EZChartProgress.staggered(
    index: index,
    count: items.count,
    progress: progress,
    itemDuration: 0.5
)
```

Returns an eased progress value for one item in a sequence.

### `EZChartReveal.horizontal`

```swift
EZAnimatedChart(reveal: .horizontal) { _ in
    // Full-value line or area marks
}
```

Masks the chart plot area from leading edge to trailing edge.

## Demo App

The demo app lives in `Examples/EZChartsDemo`. It shows:

- A staggered bar growth chart.
- A horizontal line reveal chart.
- Replay buttons.
- Copyable usage recipes inside the app UI.

Build and launch it with:

```sh
./scripts/build_and_launch.sh
```

The script uses `xcodebuild`, boots the default simulator, installs the app, launches it, and captures a local screenshot. The default simulator is `iPhone 17`.

Override the simulator:

```sh
SIMULATOR_NAME="iPad Pro 11-inch (M5)" ./scripts/build_and_launch.sh
```

Override the screenshot delay:

```sh
SCREENSHOT_DELAY=6 ./scripts/build_and_launch.sh
```

## Tips

- Set a stable `.chartYScale(domain:)` when animating bars so the axis does not rescale during the animation.
- Use `scaled` for bars and other marks that should grow from zero.
- Use `reveal: .horizontal` for line and area charts where the full shape should draw across the plot.
- Keep using normal Swift Charts modifiers for styling, axes, legends, foreground styles, interpolation, and layout.
