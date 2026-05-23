#if compiler(>=6.2)
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
        EZChart3DProgressDriver(animation: animation, replayToken: replayToken) { progress in
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

@available(iOS 26.0, macOS 26.0, *)
private struct EZChart3DProgressDriver<Content: View>: View {
    private let animation: EZChartAnimation
    private let replayToken: AnyHashable?
    private let content: (Double) -> Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress = 0.0

    init(
        animation: EZChartAnimation,
        replayToken: AnyHashable?,
        @ViewBuilder content: @escaping (Double) -> Content
    ) {
        self.animation = animation
        self.replayToken = replayToken
        self.content = content
    }

    var body: some View {
        content(progress)
            .task(id: EZChart3DPlaybackKey(replayToken: replayToken, reduceMotion: reduceMotion)) {
                await play(reduceMotion: reduceMotion)
            }
    }

    @MainActor
    private func play(reduceMotion: Bool) async {
        guard !reduceMotion else {
            progress = 1
            return
        }

        progress = 0

        let clock = ContinuousClock()
        let delay = max(animation.delay, 0)
        if delay > 0 {
            try? await clock.sleep(for: .seconds(delay))
        }

        let duration = max(animation.duration, 0.001)
        let start = clock.now

        while !Task.isCancelled {
            let elapsed = start.duration(to: clock.now).timeInterval
            let rawProgress = elapsed / duration
            progress = animation.progress(at: rawProgress)

            if rawProgress >= 1 {
                progress = 1
                return
            }

            try? await clock.sleep(for: .milliseconds(16), tolerance: .milliseconds(2))
        }
    }
}

private struct EZChart3DPlaybackKey: Equatable {
    let replayToken: AnyHashable?
    let reduceMotion: Bool
}

private extension Duration {
    static func seconds(_ value: Double) -> Duration {
        .nanoseconds(Int64((value * 1_000_000_000).rounded()))
    }

    var timeInterval: TimeInterval {
        let durationComponents = self.components
        return TimeInterval(durationComponents.seconds) + TimeInterval(durationComponents.attoseconds) / 1_000_000_000_000_000_000
    }
}
#endif
