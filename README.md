# EZCharts

`EZCharts` is a small Swift package that makes Swift Charts animations easier to reuse. It gives you:

- `EZAnimatedChart`, a wrapper around `Chart` that drives an animation progress value from `0` to `1`.
- `EZAnimatedSectorChart`, a high-level donut and pie chart wrapper with true slice-by-slice sweep animation.
- `EZCharts3D`, a separate product with `EZAnimatedChart3D` for `Chart3D` on iOS 26 and macOS 26.
- `EZChartProgress.scaled`, for marks that should grow from zero to their final value.
- `EZChartProgress.staggered`, for overlapping cascade animations.
- `EZChartProgress.sequenced`, for one-by-one mark animations.
- `EZChart3DProgress`, a 3D-specific namespace for animated 3D mark values.
- `EZChartReveal.horizontal`, for line and area charts that should draw across the plot from left to right.
- `EZChartDomain.zeroBased` and `.ezChartYScale(for:)`, for keeping the chart axis stable while values animate.

The package is intentionally light. You still write normal Swift Charts marks, scales, styles, and axes. `EZCharts` only provides the reusable animation timing.

> On watchOS, reveal masks apply to the entire chart because `chartPlotStyle(content:)` is unavailable. Unlike the plot-only mask used on other platforms, this fallback also clips axes and legends while the reveal runs. Prefer minimal or hidden axes on compact watch charts. `EZCharts3D` builds as an empty module on watchOS; `EZAnimatedChart3D` is intentionally unavailable there.

## Requirements

- Swift 5.9+
- iOS 16+
- macOS 13+
- SwiftUI
- Swift Charts

`EZCharts3D` requires an Xcode toolchain with the iOS 26/macOS 26 Swift Charts SDK. The base `EZCharts` product is separate so apps that only need 2D charts do not need to compile `Chart3D` symbols.

## Installation

In Xcode:

1. Open your app project.
2. Choose `File > Add Package Dependencies`.
3. Paste:

```text
https://github.com/gomez1112/EZCharts.git
```

4. To use the latest unreleased API shown in this README, select `Branch` and enter `main`.
5. Add the `EZCharts` product to your app target.
6. If you use `Chart3D`, also add the `EZCharts3D` product to your app target.

In `Package.swift`:

```swift
.package(url: "https://github.com/gomez1112/EZCharts.git", branch: "main")
```

Then add `EZCharts` to the target that uses normal 2D charts:

```swift
.target(
    name: "YourApp",
    dependencies: ["EZCharts"]
)
```

If the same target uses `Chart3D`, add both products:

```swift
.target(
    name: "YourApp",
    dependencies: [
        "EZCharts",
        "EZCharts3D"
    ]
)
```

For the current release, prefer version-based installation:

```swift
.package(url: "https://github.com/gomez1112/EZCharts.git", from: "0.2.3")
```

## Importing

Use both `Charts` and `EZCharts` in the SwiftUI view that draws 2D charts:

```swift
import Charts
import EZCharts
import SwiftUI
```

For `Chart3D`, import the separate 3D product too:

```swift
import Charts
import EZCharts
import EZCharts3D
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
        .ezChartYScale(for: sales.map(\.value))
        .frame(height: 280)
    }
}
```

`EZChartProgress.scaled(point.value, progress: progress)` is the key line. When `progress` is `0`, the bar is `0`. When `progress` is `1`, the bar is the real value.

Because the plotted value changes during animation, attach the final data value to each animated mark for VoiceOver, for example `.accessibilityValue(Text(point.value, format: .number))`. Accessibility should describe the stable result rather than the current interpolated frame. `EZAnimatedSectorChart` does this automatically when you provide `label:`.

`.ezChartYScale(for: sales.map(\.value))` is also important. Swift Charts normally auto-scales the Y axis from the data currently inside the chart. During an animation, your data changes every frame because the values move from `0` to their final value. A stable Y scale keeps the baseline pinned at zero, so bars grow upward instead of looking like they are moving from the top down.

With your `Company` example, write it like this:

```swift
import Charts
import EZCharts
import SwiftUI

struct ContentView: View {
    var body: some View {
        EZAnimatedChart { progress in
            ForEach(Company.sampleData) { point in
                BarMark(
                    x: .value("Month", point.month),
                    y: .value(
                        "Revenue",
                        EZChartProgress.scaled(point.revenue, progress: progress)
                    )
                )
                .foregroundStyle(point.color)
            }
        }
        .ezChartYScale(for: Company.sampleData.map(\.revenue))
        .frame(height: 280)
    }
}

struct Company: Identifiable {
    let id = UUID()
    let revenue: Double
    let month: String
    let color: Color

    static let sampleData = [
        Company(revenue: 20_000, month: "Jan", color: .red),
        Company(revenue: 10_000, month: "Feb", color: .green),
        Company(revenue: 50_000, month: "Mar", color: .blue)
    ]
}
```

For that sample, `.ezChartYScale(for:)` calculates a domain of `0...55_000`, which gives the tallest bar 10% headroom. If you want more or less space at the top, pass `headroom`:

```swift
.ezChartYScale(for: Company.sampleData.map(\.revenue), headroom: 0.2)
```

## Staggered Bar Animation

Use `staggered` when you want a cascade where multiple bars can animate at the same time:

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
        .ezChartYScale(for: sales.map(\.value))
        .frame(height: 280)
    }
}
```

`itemDuration` controls how much of the total animation each item receives. Smaller values make each bar animate faster. In other words, `itemDuration: 0.01` means each bar gets about 1% of the total progress, so it will pop in almost instantly.

## One-by-One Bar Animation

Use `sequenced` when you want each bar to finish mostly before the next one starts:

```swift
struct SequencedSalesChart: View {
    var body: some View {
        EZAnimatedChart(
            animation: EZChartAnimation(duration: 1.5, curve: .easeOut)
        ) { progress in
            ForEach(Array(sales.enumerated()), id: \.element.id) { index, point in
                let barProgress = EZChartProgress.sequenced(
                    index: index,
                    count: sales.count,
                    progress: progress,
                    overlap: 0.08
                )

                BarMark(
                    x: .value("Month", point.month),
                    y: .value(
                        "Sales",
                        EZChartProgress.scaled(point.value, progress: barProgress)
                    )
                )
            }
        }
        .ezChartYScale(for: sales.map(\.value))
        .frame(height: 280)
    }
}
```

For your sample with three bars, this is the version to use:

```swift
EZAnimatedChart(
    animation: EZChartAnimation(duration: 1.5, curve: .easeOut)
) { progress in
    ForEach(Array(Company.sampleData.enumerated()), id: \.element.id) { index, point in
        let barProgress = EZChartProgress.sequenced(
            index: index,
            count: Company.sampleData.count,
            progress: progress
        )

        BarMark(
            x: .value("Month", point.month),
            y: .value(
                "Sales",
                EZChartProgress.scaled(point.revenue, progress: barProgress)
            )
        )
        .foregroundStyle(point.color)
    }
}
.ezChartYScale(for: Company.sampleData.map(\.revenue))
.frame(height: 280)
```

Increase the `EZChartAnimation` duration when you want the whole sequence to feel slower. Use `overlap` when you want the next item to start slightly before the current item finishes.

## Sector Mark Animation

`SectorMark` is available on iOS 17 and newer. Use `EZAnimatedSectorChart` for the common case. It handles the explicit angle ranges internally, so each slice sweeps into its final position without making you calculate ranges yourself.

```swift
struct ChannelPoint: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
}

let channels = [
    ChannelPoint(name: "Direct", value: 42, color: .teal),
    ChannelPoint(name: "Search", value: 28, color: .blue),
    ChannelPoint(name: "Social", value: 18, color: .pink),
    ChannelPoint(name: "Email", value: 12, color: .orange)
]

struct ChannelChart: View {
    var body: some View {
        EZAnimatedSectorChart(
            channels,
            id: \.id,
            value: \.value,
            animation: EZChartAnimation(duration: 1.7, curve: .easeOut)
        ) { point in
            point.color
        }
        .frame(height: 280)
    }
}
```

That is the whole public API for the normal sector animation. Pass your data, tell EZCharts which property is the stable identity, tell it which numeric property represents the slice value, and optionally return a style.

`id:` is recommended when the data can be inserted, removed, or reordered. If you omit it, EZCharts uses the item offset, which is fine for static samples but weaker for dynamic data.

If you want a pie chart instead of the default donut style, pass `.pie`:

```swift
EZAnimatedSectorChart(
    channels,
    id: \.id,
    value: \.value,
    style: .pie
) { point in
    point.color
}
```

For deeper customization, create an `EZSectorChartStyle`:

```swift
let style = EZSectorChartStyle(
    innerRadius: .ratio(0.58),
    outerRadius: .ratio(1),
    angularInset: 2,
    cornerRadius: 6,
    overlap: 0.12
)

EZAnimatedSectorChart(
    channels,
    id: \.id,
    value: \.value,
    style: style
) { point in
    point.color
}
```

The style closure accepts any SwiftUI `ShapeStyle`, not only `Color`. For example:

```swift
EZAnimatedSectorChart(
    channels,
    id: \.id,
    value: \.value
) { point in
    LinearGradient(
        colors: [point.color.opacity(0.65), point.color],
        startPoint: .top,
        endPoint: .bottom
    )
}
```

## Chart3D Animation

`Chart3D` is available in Swift Charts on iOS 26, macOS 26, and visionOS 26. It has a separate product and API: add `EZCharts3D`, import `EZCharts3D`, then use `EZAnimatedChart3D`.

`EZAnimatedChart3D` drives progress frame by frame because 3D marks should not rely on the same implicit interpolation behavior as 2D charts.

```swift
struct PipelinePoint: Identifiable {
    let id = UUID()
    let acquisition: Double
    let revenue: Double
    let retention: Double
}

let pipeline = [
    PipelinePoint(acquisition: 18, revenue: 24, retention: 32),
    PipelinePoint(acquisition: 36, revenue: 48, retention: 50),
    PipelinePoint(acquisition: 58, revenue: 68, retention: 64),
    PipelinePoint(acquisition: 82, revenue: 88, retention: 78)
]

@available(iOS 26.0, *)
struct Pipeline3DChart: View {
    @State private var pose = Chart3DPose(
        azimuth: .degrees(35),
        inclination: .degrees(18)
    )

    var body: some View {
        EZAnimatedChart3D(
            animation: EZChartAnimation(duration: 2.2, curve: .easeOut)
        ) { progress in
            ForEach(Array(pipeline.enumerated()), id: \.element.id) { index, point in
                let pointProgress = EZChart3DProgress.sequenced(
                    index: index,
                    count: pipeline.count,
                    progress: progress,
                    overlap: 0.05
                )
                let animatedRevenue = EZChart3DProgress.scaled(
                    point.revenue,
                    progress: pointProgress
                )

                PointMark(
                    x: .value("Acquisition", point.acquisition),
                    y: .value("Revenue", animatedRevenue),
                    z: .value("Retention", point.retention)
                )
                .symbolSize(0.015 + (0.055 * pointProgress))
            }
        }
        .chart3DPose($pose)
        .chartXAxisLabel("Acquisition")
        .chartYAxisLabel("Revenue")
        .chartZAxisLabel("Retention")
        .chartXScale(domain: 0...100, range: -0.5...0.5)
        .chartYScale(domain: 0...100, range: -0.5...0.5)
        .chartZScale(domain: 0...100, range: -0.5...0.5)
        .frame(height: 320)
    }
}
```

Use `EZChart3DProgress` for 3D marks. It mirrors the timing ideas from 2D, but it keeps the 3D API visibly separate.

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
            .ezChartYScale(for: sales.map(\.value))
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

## Reduce Motion

EZCharts respects the system Reduce Motion setting. When Reduce Motion is enabled, `EZAnimatedChart`, `EZAnimatedSectorChart`, and `EZAnimatedChart3D` skip directly to their final progress value instead of running the frame-by-frame animation.

You do not need to add extra code for this behavior. Keep using the same chart wrappers and progress helpers.

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

### `EZAnimatedSectorChart`

```swift
EZAnimatedSectorChart(
    data,
    id: \.id,
    value: \.value,
    animation: EZChartAnimation = .init(duration: 1.7, curve: .easeOut),
    replayToken: AnyHashable? = nil,
    style: EZSectorChartStyle = .donut
) { point in
    point.color
}
```

Use this for pie and donut charts. It hides the `SectorMark` angle-range work needed for true slice sweep animation. The style closure can return any `ShapeStyle`, including `Color` and `LinearGradient`.

### `EZAnimatedChart3D`

```swift
EZAnimatedChart3D(
    animation: EZChartAnimation = .smooth,
    replayToken: AnyHashable? = nil
) { progress in
    // Chart3DContent
}
```

Use this from the `EZCharts3D` product for `Chart3D` on iOS 26 and macOS 26. The closure must return 3D chart content such as `PointMark(x:y:z:)`, `RectangleMark(x:y:z:)`, or `RuleMark` variants that conform to `Chart3DContent`.

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

Returns an eased progress value for one item in an overlapping cascade. `itemDuration` is the fraction of total progress used by each item, so smaller values animate each item faster.

### `EZChartProgress.sequenced`

```swift
EZChartProgress.sequenced(
    index: index,
    count: items.count,
    progress: progress,
    overlap: 0.08
)
```

Returns an eased progress value for one item in a one-by-one sequence. With the default `overlap: 0`, each item waits for the previous item to finish. Increase `overlap` when you want a softer handoff.

### `EZChart3DProgress`

```swift
EZChart3DProgress.scaled(value, progress: progress)
EZChart3DProgress.sequenced(index: index, count: count, progress: progress)
EZChart3DProgress.staggered(index: index, count: count, progress: progress)
```

Use these helpers inside `EZAnimatedChart3D`. They intentionally live in a separate namespace so 3D chart code reads differently from 2D chart code.

### `EZChartProgress.sectorRanges` and `revealedRange`

```swift
let ranges = EZChartProgress.sectorRanges(
    for: data.map(\.value)
)
let range = EZChartProgress.revealedRange(ranges[index], progress: progress)
```

These are low-level helpers used by `EZAnimatedSectorChart`. Most apps should use `EZAnimatedSectorChart` directly.

### `EZChartReveal.horizontal`

```swift
EZAnimatedChart(reveal: .horizontal) { _ in
    // Full-value line or area marks
}
```

Masks the chart plot area from leading edge to trailing edge.

### `EZChartDomain.zeroBased`

```swift
EZChartDomain.zeroBased([20_000, 10_000, 50_000])
```

Returns a stable `ClosedRange<Double>` you can pass to Swift Charts. The lower bound includes zero, and positive values receive 10% headroom by default. The example above returns `0...55_000`.

### `.ezChartYScale(for:)`

```swift
EZAnimatedChart { progress in
    // Animated bar marks
}
.ezChartYScale(for: data.map(\.value))
```

Convenience modifier for applying `EZChartDomain.zeroBased` directly to an animated chart. Use this for bar charts that animate their Y values with `EZChartProgress.scaled`.

## Demo App

The demo app lives in `Examples/EZChartsDemo`. It shows:

- A sequenced bar growth chart.
- A horizontal line reveal chart.
- A simplified sector chart with true per-slice sweep animation.
- A Chart3D point chart driven by `EZAnimatedChart3D`.
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

- Set a stable Y scale when animating bars so the axis does not rescale during the animation. Prefer `.ezChartYScale(for: data.map(\.value))`, or use Swift Charts' `.chartYScale(domain:)` directly when you already know the exact domain.
- Use `scaled` for bars and other marks that should grow from zero.
- Use `sequenced` for one-by-one 2D marks.
- Use `EZAnimatedSectorChart` before reaching for manual `SectorMark` ranges.
- Use `EZAnimatedChart3D` and `EZChart3DProgress` for `Chart3D`; use `EZAnimatedChart` for normal `Chart` plus built-in 2D reveal effects.
- Use a longer `EZChartAnimation(duration:)` when the entire sequence feels too fast.
- Use `reveal: .horizontal` for line and area charts where the full shape should draw across the plot.
- Keep using normal Swift Charts modifiers for styling, axes, legends, foreground styles, interpolation, and layout.
