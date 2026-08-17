import Foundation

/// Pure progress calculations for animated chart marks.
public enum EZChartProgress {
    /// Local easing composed after the outer chart animation curve.
    public struct Easing: Equatable, Sendable {
        private enum Kind: Equatable, Sendable { case linear, smoothstep }
        private let kind: Kind
        private init(_ kind: Kind) { self.kind = kind }
        public static let linear = Easing(.linear)
        public static let smoothstep = Easing(.smoothstep)

        fileprivate func callAsFunction(_ progress: Double) -> Double {
            switch kind {
            case .linear: progress
            case .smoothstep: progress * progress * (3 - 2 * progress)
            }
        }
    }

    public static func clamped(_ progress: Double) -> Double { min(max(progress, 0), 1) }
    public static func scaled(_ value: Double, progress: Double) -> Double { value * clamped(progress) }

    public static func staggered(
        index: Int,
        count: Int,
        progress: Double,
        itemDuration: Double = 0.5,
        easing: Easing = .smoothstep
    ) -> Double {
        guard count > 0 else { return 0 }
        guard count > 1 else { return easing(clamped(progress)) }
        let boundedIndex = min(max(index, 0), count - 1)
        let boundedDuration = min(max(itemDuration, 0.05), 1)
        let start = Double(boundedIndex) / Double(count - 1) * (1 - boundedDuration)
        return easing(clamped((clamped(progress) - start) / boundedDuration))
    }

    public static func sequenced(
        index: Int,
        count: Int,
        progress: Double,
        overlap: Double = 0,
        easing: Easing = .smoothstep
    ) -> Double {
        guard count > 0 else { return 0 }
        guard count > 1 else { return easing(clamped(progress)) }
        let boundedIndex = min(max(index, 0), count - 1)
        let boundedOverlap = min(max(overlap, 0), 0.95)
        let itemDuration = 1 / (Double(count) - (Double(count - 1) * boundedOverlap))
        let start = Double(boundedIndex) * itemDuration * (1 - boundedOverlap)
        return easing(clamped((clamped(progress) - start) / itemDuration))
    }

    public static func sectorRanges<Values: Sequence>(for values: Values) -> [Range<Double>]
    where Values.Element: EZChartValue {
        let normalizedValues = values.map { value in
            let value = value.ezChartValue
            return value.isFinite && value > 0 ? value : 0
        }
        let total = normalizedValues.reduce(0, +)
        guard total.isFinite, total > 0 else { return normalizedValues.map { _ in 0..<0 } }
        var start = 0.0
        return normalizedValues.map { value in
            let end = start + (value / total)
            defer { start = end }
            return start..<end
        }
    }

    public static func revealedRange(_ range: Range<Double>, progress: Double) -> Range<Double> {
        let span = max(range.upperBound - range.lowerBound, 0)
        return range.lowerBound..<(range.lowerBound + span * clamped(progress))
    }
}
