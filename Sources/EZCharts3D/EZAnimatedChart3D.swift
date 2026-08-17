#if os(iOS) || os(macOS) || os(visionOS)
import Charts
import EZCharts
import SwiftUI

@available(iOS 26.0, macOS 26.0, *)
public struct EZAnimatedChart3D<Content: Chart3DContent>: View {
    private let animation: EZChartAnimation
    private let replayToken: AnyHashable?
    private let content: (Double) -> Content

    public init(
        animation: EZChartAnimation = .smooth,
        replayToken: AnyHashable? = nil,
        @Chart3DContentBuilder content: @escaping (Double) -> Content
    ) {
        self.animation = animation
        self.replayToken = replayToken
        self.content = content
    }

    public var body: some View {
        EZChartProgressPlayback(animation: animation, replayToken: replayToken) { progress in
            Chart3D {
                content(progress)
            }
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
/// A 3D-specific facade that forwards progress calculations to ``EZCharts/EZChartProgress``.
public enum EZChart3DProgress {
    /// Forwards to ``EZCharts/EZChartProgress/scaled(_:progress:)``.
    public static func scaled(_ value: Double, progress: Double) -> Double {
        EZChartProgress.scaled(value, progress: progress)
    }

    /// Forwards to ``EZCharts/EZChartProgress/sequenced(index:count:progress:overlap:)``.
    public static func sequenced(
        index: Int,
        count: Int,
        progress: Double,
        overlap: Double = 0,
        easing: EZChartProgress.Easing = .smoothstep
    ) -> Double {
        EZChartProgress.sequenced(index: index, count: count, progress: progress, overlap: overlap, easing: easing)
    }

    /// Forwards to ``EZCharts/EZChartProgress/staggered(index:count:progress:itemDuration:)``.
    public static func staggered(
        index: Int,
        count: Int,
        progress: Double,
        itemDuration: Double = 0.5,
        easing: EZChartProgress.Easing = .smoothstep
    ) -> Double {
        EZChartProgress.staggered(index: index, count: count, progress: progress, itemDuration: itemDuration, easing: easing)
    }
}

#endif
