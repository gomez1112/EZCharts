# Getting Started With EZCharts

Use `EZAnimatedChart` where you would normally use `Chart`.

```swift
import Charts
import EZCharts
import SwiftUI

struct SalesPoint: Identifiable {
    let id = UUID()
    let month: String
    let value: Double
}

struct SalesChart: View {
    let data: [SalesPoint]

    var body: some View {
        EZAnimatedChart { progress in
            ForEach(data) { point in
                BarMark(
                    x: .value("Month", point.month),
                    y: .value("Sales", EZChartProgress.scaled(point.value, progress: progress))
                )
            }
        }
        .ezChartYScale(for: data.map(\.value))
        .frame(height: 280)
    }
}
```

Use `EZChartProgress.sequenced` when each mark should animate one by one.

```swift
EZAnimatedChart(animation: EZChartAnimation(duration: 1.8, curve: .easeOut)) { progress in
    ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
        let itemProgress = EZChartProgress.sequenced(
            index: index,
            count: data.count,
            progress: progress,
            overlap: 0.05
        )

        BarMark(
            x: .value("Month", point.month),
            y: .value("Sales", EZChartProgress.scaled(point.value, progress: itemProgress))
        )
    }
}
```

Use `EZAnimatedSectorChart` for pie and donut charts.

```swift
EZAnimatedSectorChart(
    channels,
    id: \.id,
    value: \.value,
    style: .donut
) { channel in
    channel.color
}
```
