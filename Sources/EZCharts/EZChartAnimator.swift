import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
struct EZChartProgressDriver<Content: View>: View {
    private let animation: EZChartAnimation
    private let replayToken: AnyHashable?
    private let content: (Double) -> Content

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
            .task(id: replayToken) {
                await play()
            }
    }

    @MainActor
    private func play() async {
        progress = 0

        let delay = max(animation.delay, 0)
        if delay > 0 {
            let nanoseconds = UInt64(delay * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
        }

        let duration = max(animation.duration, 0.001)
        let start = Date()

        while !Task.isCancelled {
            let elapsed = Date().timeIntervalSince(start)
            let rawProgress = elapsed / duration
            progress = animation.progress(at: rawProgress)

            if rawProgress >= 1 {
                progress = 1
                return
            }

            try? await Task.sleep(nanoseconds: 16_000_000)
        }
    }
}

@available(iOS 16.0, macOS 13.0, *)
@available(*, deprecated, message: "Use EZAnimatedChart for 2D charts or EZAnimatedChart3D for Chart3D.")
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
