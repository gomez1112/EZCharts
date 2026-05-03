import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
public struct EZChartAnimator<Content: View>: View {
    private let animation: EZChartAnimation
    private let replayToken: AnyHashable?
    private let content: (Double) -> Content

    @State private var progress = 0.0

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

        withAnimation(animation.swiftUIAnimation) {
            progress = 1
        }
    }
}
