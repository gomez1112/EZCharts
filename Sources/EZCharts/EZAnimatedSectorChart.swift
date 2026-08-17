import Charts
import SwiftUI

public struct EZSectorChartStyle: Sendable {
    public var innerRadius: MarkDimension
    public var outerRadius: MarkDimension
    public var angularInset: CGFloat?
    public var cornerRadius: CGFloat
    public var overlap: Double
    public var valueLabel: LocalizedStringResource
    public var legendVisibility: Visibility

    public init(
        innerRadius: MarkDimension = .ratio(0.52),
        outerRadius: MarkDimension = .ratio(1),
        angularInset: CGFloat? = 2,
        cornerRadius: CGFloat = 5,
        overlap: Double = 0.08,
        valueLabel: LocalizedStringResource = LocalizedStringResource("Share", bundle: .module),
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
        valueLabel: LocalizedStringResource("Share", bundle: .module),
        legendVisibility: .hidden
    )
}

public struct EZAnimatedSectorChart<Data: RandomAccessCollection>: View {
    private let sectors: [EZIndexedSector<Data.Element>]
    private let animation: EZChartAnimation
    private let replayToken: AnyHashable?
    private let style: EZSectorChartStyle

    /// Creates a sector chart using an explicit stable identifier and the default palette.
    public init<ID, Value>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        value: KeyPath<Data.Element, Value>,
        label: KeyPath<Data.Element, String>? = nil,
        animation: EZChartAnimation = EZChartAnimation(duration: 1.7, curve: .easeOut),
        replayToken: AnyHashable? = nil,
        style: EZSectorChartStyle = .donut
    ) where ID: Hashable, Value: EZChartValue {
        self.init(
            data,
            id: { AnyHashable($0[keyPath: id]) },
            value: { $0[keyPath: value].ezChartValue },
            label: label.map { keyPath in { $0[keyPath: keyPath] } },
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: { _, index in AnyShapeStyle(EZSectorPalette.color(at: index)) }
        )
    }

    /// Creates a sector chart using an explicit stable identifier and custom slice styles.
    public init<ID, Value, Style>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        value: KeyPath<Data.Element, Value>,
        label: KeyPath<Data.Element, String>? = nil,
        animation: EZChartAnimation = EZChartAnimation(duration: 1.7, curve: .easeOut),
        replayToken: AnyHashable? = nil,
        style: EZSectorChartStyle = .donut,
        foregroundStyle: @escaping (Data.Element) -> Style
    ) where ID: Hashable, Value: EZChartValue, Style: ShapeStyle {
        self.init(
            data,
            id: { AnyHashable($0[keyPath: id]) },
            value: { $0[keyPath: value].ezChartValue },
            label: label.map { keyPath in { $0[keyPath: keyPath] } },
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: { element, _ in AnyShapeStyle(foregroundStyle(element)) }
        )
    }

    private init(
        _ data: Data,
        id: (Data.Element) -> AnyHashable,
        value: (Data.Element) -> Double,
        label: ((Data.Element) -> String)?,
        animation: EZChartAnimation,
        replayToken: AnyHashable?,
        style: EZSectorChartStyle,
        foregroundStyle: (Data.Element, Int) -> AnyShapeStyle
    ) {
        sectors = data.enumerated().map { index, element in
            EZIndexedSector(
                id: id(element),
                index: index,
                element: element,
                value: value(element),
                label: label?(element),
                foregroundStyle: foregroundStyle(element, index)
            )
        }
        self.animation = animation
        self.replayToken = replayToken
        self.style = style
    }

    public var body: some View {
        let sectorRanges = EZChartProgress.sectorRanges(for: sectors.map(\.value))
        let total = sectors.reduce(0) { partialResult, sector in
            partialResult + (sector.value.isFinite && sector.value > 0 ? sector.value : 0)
        }

        EZChartProgressPlayback(animation: animation, replayToken: replayToken) { progress in
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
                        angle: .value(sector.label ?? String(localized: style.valueLabel), revealedRange),
                        innerRadius: style.innerRadius,
                        outerRadius: style.outerRadius,
                        angularInset: style.angularInset
                    )
                    .cornerRadius(style.cornerRadius)
                    .foregroundStyle(sector.foregroundStyle)
                    .accessibilityLabel(sector.label ?? String(localized: style.valueLabel))
                    .accessibilityValue(accessibilityValue(for: sector.value, total: total))
                }
            }
            .chartLegend(style.legendVisibility)
        }
    }

    private func accessibilityValue(for value: Double, total: Double) -> String {
        let normalizedValue = value.isFinite && value > 0 ? value : 0
        let percentage = total > 0 ? normalizedValue / total : 0
        return "\(normalizedValue.formatted(.number)), \(percentage.formatted(.percent.precision(.fractionLength(0))))"
    }
}

public extension EZAnimatedSectorChart where Data.Element: Identifiable {
    /// Creates a sector chart using each element's `Identifiable` identity and the default palette.
    init<Value>(
        _ data: Data,
        value: KeyPath<Data.Element, Value>,
        label: KeyPath<Data.Element, String>? = nil,
        animation: EZChartAnimation = EZChartAnimation(duration: 1.7, curve: .easeOut),
        replayToken: AnyHashable? = nil,
        style: EZSectorChartStyle = .donut
    ) where Value: EZChartValue {
        self.init(data, id: \.id, value: value, label: label, animation: animation, replayToken: replayToken, style: style)
    }

    /// Creates a sector chart using each element's `Identifiable` identity and custom slice styles.
    init<Value, Style>(
        _ data: Data,
        value: KeyPath<Data.Element, Value>,
        label: KeyPath<Data.Element, String>? = nil,
        animation: EZChartAnimation = EZChartAnimation(duration: 1.7, curve: .easeOut),
        replayToken: AnyHashable? = nil,
        style: EZSectorChartStyle = .donut,
        foregroundStyle: @escaping (Data.Element) -> Style
    ) where Value: EZChartValue, Style: ShapeStyle {
        self.init(
            data,
            id: \.id,
            value: value,
            label: label,
            animation: animation,
            replayToken: replayToken,
            style: style,
            foregroundStyle: foregroundStyle
        )
    }
}

private struct EZIndexedSector<Element>: Identifiable {
    let id: AnyHashable
    let index: Int
    let element: Element
    let value: Double
    let label: String?
    let foregroundStyle: AnyShapeStyle
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
