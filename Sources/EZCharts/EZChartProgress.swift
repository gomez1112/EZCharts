import Foundation

public enum EZChartProgress {
    public static func clamped(_ progress: Double) -> Double {
        min(max(progress, 0), 1)
    }

    public static func scaled(_ value: Double, progress: Double) -> Double {
        value * clamped(progress)
    }

    public static func staggered(
        index: Int,
        count: Int,
        progress: Double,
        itemDuration: Double = 0.5
    ) -> Double {
        guard count > 1 else {
            return eased(clamped(progress))
        }

        let boundedDuration = min(max(itemDuration, 0.05), 1)
        let latestStart = 1 - boundedDuration
        let start = Double(max(index, 0)) / Double(count - 1) * latestStart
        let localProgress = (clamped(progress) - start) / boundedDuration

        return eased(clamped(localProgress))
    }

    public static func sequenced(
        index: Int,
        count: Int,
        progress: Double,
        overlap: Double = 0
    ) -> Double {
        guard count > 1 else {
            return eased(clamped(progress))
        }

        let boundedIndex = min(max(index, 0), count - 1)
        let boundedOverlap = min(max(overlap, 0), 0.95)
        let itemDuration = 1 / (Double(count) - (Double(count - 1) * boundedOverlap))
        let start = Double(boundedIndex) * itemDuration * (1 - boundedOverlap)
        let localProgress = (clamped(progress) - start) / itemDuration

        return eased(clamped(localProgress))
    }

    private static func eased(_ progress: Double) -> Double {
        progress * progress * (3 - 2 * progress)
    }
}
