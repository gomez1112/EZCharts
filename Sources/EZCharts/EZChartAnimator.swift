import SwiftUI

package struct EZChartProgressDriver<Content: View>: View, Animatable {
    package var progress: Double
    package let content: (Double) -> Content

    package init(
        progress: Double,
        @ViewBuilder content: @escaping (Double) -> Content
    ) {
        self.progress = progress
        self.content = content
    }

    package var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    package var body: some View {
        content(progress)
    }
}

package struct EZChartProgressPlayback<Content: View>: View {
    private let animation: EZChartAnimation
    private let replayToken: AnyHashable?
    private let content: (Double) -> Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var target = 0.0

    package init(
        animation: EZChartAnimation = .smooth,
        replayToken: AnyHashable? = nil,
        @ViewBuilder content: @escaping (Double) -> Content
    ) {
        self.animation = animation
        self.replayToken = replayToken
        self.content = content
    }

    package var body: some View {
        EZChartProgressDriver(progress: target, content: content)
            .animation(reduceMotion ? nil : animation.swiftUIAnimation, value: target)
            .task(id: replayToken) {
                var resetTransaction = Transaction(animation: nil)
                resetTransaction.disablesAnimations = true
                withTransaction(resetTransaction) {
                    target = 0
                }
                await Task.yield()
                target = 1
            }
            .onChange(of: reduceMotion) {
                target = 1
            }
    }
}
