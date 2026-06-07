import Charts
import SwiftUI

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
public struct EZSectorChartStyle {
    public var innerRadius: MarkDimension
    public var outerRadius: MarkDimension
    public var angularInset: CGFloat?
    public var cornerRadius: CGFloat
    public var overlap: Double
    public var valueLabel: String
    public var legendVisibility: Visibility

    public init(
        innerRadius: MarkDimension = .ratio(0.52),
        outerRadius: MarkDimension = .ratio(1),
        angularInset: CGFloat? = 2,
        cornerRadius: CGFloat = 5,
        overlap: Double = 0.08,
        valueLabel: String = "Share",
        legendVisibility: Visibility = .hidden
    ) {
        self.innerRadius = innerRadius
        self.outerRadius = outerRadius
        self.angularInset = angularInset
        self.cornerRadius = cornerRadius
        self.overlap = overlap
        self.valueLabel = valueLabel
        self.legendVisibility = legendVisibility
    }

    public static let donut = EZSectorChartStyle()

    public static let pie = EZSectorChartStyle(
        innerRadius: .ratio(0),
        outerRadius: .ratio(1),
        angularInset: 1,
        cornerRadius: 4,
        overlap: 0.08,
        valueLabel: "Share",
        legendVisibility: .hidden
    )
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
public struct EZAnimatedSectorChart<Data: RandomAccessCollection>: View {
    private let sectors: [EZIndexedSector<Data.Element>]
    private let value: (Data.Element) -> Double
    private let foregroundStyle: (Data.Element, Int) -> AnyShapeStyle
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
            id: { _, index in AnyHashable(index) },
            value: { Double($0[keyPath: value]) },
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: { _, index in AnyShapeStyle(EZSectorPalette.color(at: index)) }
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
            id: { _, index in AnyHashable(index) },
            value: { Double($0[keyPath: value]) },
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: { _, index in AnyShapeStyle(EZSectorPalette.color(at: index)) }
        )
    }

    public init<Value, Style>(
        _ data: Data,
        value: KeyPath<Data.Element, Value>,
        animation: EZChartAnimation = EZChartAnimation(duration: 1.7, curve: .easeOut),
        replayToken: AnyHashable? = nil,
        style: EZSectorChartStyle = .donut,
        foregroundStyle: @escaping (Data.Element) -> Style
    ) where Value: BinaryFloatingPoint, Style: ShapeStyle {
        self.init(
            data,
            id: { _, index in AnyHashable(index) },
            value: { Double($0[keyPath: value]) },
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: { element, _ in AnyShapeStyle(foregroundStyle(element)) }
        )
    }

    public init<Value, Style>(
        _ data: Data,
        value: KeyPath<Data.Element, Value>,
        animation: EZChartAnimation = EZChartAnimation(duration: 1.7, curve: .easeOut),
        replayToken: AnyHashable? = nil,
        style: EZSectorChartStyle = .donut,
        foregroundStyle: @escaping (Data.Element) -> Style
    ) where Value: BinaryInteger, Style: ShapeStyle {
        self.init(
            data,
            id: { _, index in AnyHashable(index) },
            value: { Double($0[keyPath: value]) },
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: { element, _ in AnyShapeStyle(foregroundStyle(element)) }
        )
    }

    public init<ID, Value>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        value: KeyPath<Data.Element, Value>,
        animation: EZChartAnimation = EZChartAnimation(duration: 1.7, curve: .easeOut),
        replayToken: AnyHashable? = nil,
        style: EZSectorChartStyle = .donut
    ) where ID: Hashable, Value: BinaryFloatingPoint {
        self.init(
            data,
            id: { element, _ in AnyHashable(element[keyPath: id]) },
            value: { Double($0[keyPath: value]) },
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: { _, index in AnyShapeStyle(EZSectorPalette.color(at: index)) }
        )
    }

    public init<ID, Value>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        value: KeyPath<Data.Element, Value>,
        animation: EZChartAnimation = EZChartAnimation(duration: 1.7, curve: .easeOut),
        replayToken: AnyHashable? = nil,
        style: EZSectorChartStyle = .donut
    ) where ID: Hashable, Value: BinaryInteger {
        self.init(
            data,
            id: { element, _ in AnyHashable(element[keyPath: id]) },
            value: { Double($0[keyPath: value]) },
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: { _, index in AnyShapeStyle(EZSectorPalette.color(at: index)) }
        )
    }

    public init<ID, Value, Style>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        value: KeyPath<Data.Element, Value>,
        animation: EZChartAnimation = EZChartAnimation(duration: 1.7, curve: .easeOut),
        replayToken: AnyHashable? = nil,
        style: EZSectorChartStyle = .donut,
        foregroundStyle: @escaping (Data.Element) -> Style
    ) where ID: Hashable, Value: BinaryFloatingPoint, Style: ShapeStyle {
        self.init(
            data,
            id: { element, _ in AnyHashable(element[keyPath: id]) },
            value: { Double($0[keyPath: value]) },
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: { element, _ in AnyShapeStyle(foregroundStyle(element)) }
        )
    }

    public init<ID, Value, Style>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        value: KeyPath<Data.Element, Value>,
        animation: EZChartAnimation = EZChartAnimation(duration: 1.7, curve: .easeOut),
        replayToken: AnyHashable? = nil,
        style: EZSectorChartStyle = .donut,
        foregroundStyle: @escaping (Data.Element) -> Style
    ) where ID: Hashable, Value: BinaryInteger, Style: ShapeStyle {
        self.init(
            data,
            id: { element, _ in AnyHashable(element[keyPath: id]) },
            value: { Double($0[keyPath: value]) },
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: { element, _ in AnyShapeStyle(foregroundStyle(element)) }
        )
    }

    private init(
        _ data: Data,
        id: (Data.Element, Int) -> AnyHashable,
        value: @escaping (Data.Element) -> Double,
        animation: EZChartAnimation,
        replayToken: AnyHashable?,
        style: EZSectorChartStyle,
        foregroundStyle: @escaping (Data.Element, Int) -> AnyShapeStyle
    ) {
        self.sectors = data.enumerated().map { index, element in
            EZIndexedSector(
                id: id(element, index),
                index: index,
                element: element
            )
        }
        self.value = value
        self.animation = animation
        self.replayToken = replayToken
        self.style = style
        self.foregroundStyle = foregroundStyle
    }

    public var body: some View {
        let sectorRanges = EZChartProgress.sectorRanges(for: sectors.map { value($0.element) })

        EZChartProgressDriver(animation: animation, replayToken: replayToken) { progress in
            Chart {
                ForEach(sectors) { sector in
                    let sectorProgress = EZChartProgress.sequenced(
                        index: sector.index,
                        count: sectors.count,
                        progress: progress,
                        overlap: style.overlap
                    )
                    let revealedRange = EZChartProgress.revealedRange(
                        sectorRanges[sector.index],
                        progress: sectorProgress
                    )

                    SectorMark(
                        angle: .value(style.valueLabel, revealedRange),
                        innerRadius: style.innerRadius,
                        outerRadius: style.outerRadius,
                        angularInset: style.angularInset
                    )
                    .cornerRadius(style.cornerRadius)
                    .foregroundStyle(foregroundStyle(sector.element, sector.index))
                }
            }
            .chartLegend(style.legendVisibility)
        }
    }
}

private struct EZIndexedSector<Element>: Identifiable {
    let id: AnyHashable
    let index: Int
    let element: Element
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
