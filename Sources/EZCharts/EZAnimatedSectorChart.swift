import Charts
import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
public struct EZSectorChartStyle {
    public var innerRadius: MarkDimension
    public var outerRadius: MarkDimension
    public var angularInset: CGFloat?
    public var cornerRadius: CGFloat
    public var overlap: Double
    public var valueLabel: String

    public init(
        innerRadius: MarkDimension = .ratio(0.52),
        outerRadius: MarkDimension = .ratio(1),
        angularInset: CGFloat? = 2,
        cornerRadius: CGFloat = 5,
        overlap: Double = 0.08,
        valueLabel: String = "Share"
    ) {
        self.innerRadius = innerRadius
        self.outerRadius = outerRadius
        self.angularInset = angularInset
        self.cornerRadius = cornerRadius
        self.overlap = overlap
        self.valueLabel = valueLabel
    }

    public static let donut = EZSectorChartStyle()

    public static let pie = EZSectorChartStyle(
        innerRadius: .ratio(0),
        outerRadius: .ratio(1),
        angularInset: 1,
        cornerRadius: 4,
        overlap: 0.08,
        valueLabel: "Share"
    )
}

@available(iOS 17.0, macOS 14.0, *)
public struct EZAnimatedSectorChart<Data: RandomAccessCollection>: View {
    private let data: [Data.Element]
    private let value: (Data.Element) -> Double
    private let foregroundStyle: (Data.Element, Int) -> Color
    private let animation: EZChartAnimation
    private let replayToken: AnyHashable?
    private let style: EZSectorChartStyle

    public init<Value>(
        _ data: Data,
        value: KeyPath<Data.Element, Value>,
        animation: EZChartAnimation = EZChartAnimation(duration: 1.7, curve: .easeOut),
        replayToken: AnyHashable? = nil,
        style: EZSectorChartStyle = .donut
    ) where Value: BinaryFloatingPoint {
        self.init(
            data,
            value: { Double($0[keyPath: value]) },
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: { _, index in EZSectorPalette.color(at: index) }
        )
    }

    public init<Value>(
        _ data: Data,
        value: KeyPath<Data.Element, Value>,
        animation: EZChartAnimation = EZChartAnimation(duration: 1.7, curve: .easeOut),
        replayToken: AnyHashable? = nil,
        style: EZSectorChartStyle = .donut
    ) where Value: BinaryInteger {
        self.init(
            data,
            value: { Double($0[keyPath: value]) },
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: { _, index in EZSectorPalette.color(at: index) }
        )
    }

    public init<Value>(
        _ data: Data,
        value: KeyPath<Data.Element, Value>,
        animation: EZChartAnimation = EZChartAnimation(duration: 1.7, curve: .easeOut),
        replayToken: AnyHashable? = nil,
        style: EZSectorChartStyle = .donut,
        foregroundStyle: @escaping (Data.Element) -> Color
    ) where Value: BinaryFloatingPoint {
        self.init(
            data,
            value: { Double($0[keyPath: value]) },
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: { element, _ in foregroundStyle(element) }
        )
    }

    public init<Value>(
        _ data: Data,
        value: KeyPath<Data.Element, Value>,
        animation: EZChartAnimation = EZChartAnimation(duration: 1.7, curve: .easeOut),
        replayToken: AnyHashable? = nil,
        style: EZSectorChartStyle = .donut,
        foregroundStyle: @escaping (Data.Element) -> Color
    ) where Value: BinaryInteger {
        self.init(
            data,
            value: { Double($0[keyPath: value]) },
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: { element, _ in foregroundStyle(element) }
        )
    }

    private init(
        _ data: Data,
        value: @escaping (Data.Element) -> Double,
        animation: EZChartAnimation,
        replayToken: AnyHashable?,
        style: EZSectorChartStyle,
        foregroundStyle: @escaping (Data.Element, Int) -> Color
    ) {
        self.data = Array(data)
        self.value = value
        self.animation = animation
        self.replayToken = replayToken
        self.style = style
        self.foregroundStyle = foregroundStyle
    }

    public var body: some View {
        let sectorRanges = EZChartProgress.sectorRanges(for: data.map(value))

        EZChartProgressDriver(animation: animation, replayToken: replayToken) { progress in
            Chart {
                ForEach(Array(data.enumerated()), id: \.offset) { index, element in
                    let sectorProgress = EZChartProgress.sequenced(
                        index: index,
                        count: data.count,
                        progress: progress,
                        overlap: style.overlap
                    )
                    let revealedRange = EZChartProgress.revealedRange(
                        sectorRanges[index],
                        progress: sectorProgress
                    )

                    SectorMark(
                        angle: .value(style.valueLabel, revealedRange),
                        innerRadius: style.innerRadius,
                        outerRadius: style.outerRadius,
                        angularInset: style.angularInset
                    )
                    .cornerRadius(style.cornerRadius)
                    .foregroundStyle(foregroundStyle(element, index))
                }
            }
            .chartLegend(.hidden)
        }
    }
}

private enum EZSectorPalette {
    private static let colors: [Color] = [
        .teal,
        .blue,
        .pink,
        .orange,
        .indigo,
        .green,
        .purple
    ]

    static func color(at index: Int) -> Color {
        colors[index % colors.count]
    }
}
