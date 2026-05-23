import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
struct EZChartProgressDriver<Content: View>: View {
    private let animation: EZChartAnimation
    private let replayToken: AnyHashable?
    private let content: (Double) -> Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress = 0.0

    init(
        animation: EZChartAnimation = .smooth,
        replayToken: AnyHashable? = nil,
        @ViewBuilder content: @escaping (Double) -> Content
    ) {
        self.animation = animation
        self.replayToken = replayToken
        self.content = content
    }

    var body: some View {
        content(progress)
            .task(id: EZChartPlaybackKey(replayToken: replayToken, reduceMotion: reduceMotion)) {
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

private struct EZChartPlaybackKey: Equatable {
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

@available(iOS 16.0, macOS 13.0, *)
@available(*, deprecated, message: "Use EZAnimatedChart for 2D charts or EZAnimatedChart3D from the EZCharts3D product for Chart3D.")
public struct EZChartAnimator<Content: View>: View {
    private let animation: EZChartAnimation
    private let replayToken: AnyHashable?
    private let content: (Double) -> Content

    public init(
        animation: EZChartAnimation = .smooth,
        replayToken: AnyHashable? = nil,
        @ViewBuilder content: @escaping (Double) -> Content
    ) {
        self.animation = animation
        self.replayToken = replayToken
        self.content = content
    }

    public var body: some View {
        EZChartProgressDriver(animation: animation, replayToken: replayToken) { progress in
            content(progress)
        }
    }
}
