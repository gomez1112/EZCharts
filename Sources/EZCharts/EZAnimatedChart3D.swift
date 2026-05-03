import Charts
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
        EZChartProgressDriver(animation: animation, replayToken: replayToken) { progress in
            Chart3D {
                content(progress)
            }
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
public enum EZChart3DProgress {
    public static func scaled(_ value: Double, progress: Double) -> Double {
        EZChartProgress.scaled(value, progress: progress)
    }

    public static func sequenced(
        index: Int,
        count: Int,
        progress: Double,
        overlap: Double = 0
    ) -> Double {
        EZChartProgress.sequenced(
            index: index,
            count: count,
            progress: progress,
            overlap: overlap
        )
    }

    public static func staggered(
        index: Int,
        count: Int,
        progress: Double,
        itemDuration: Double = 0.5
    ) -> Double {
        EZChartProgress.staggered(
            index: index,
            count: count,
            progress: progress,
            itemDuration: itemDuration
        )
    }
}
