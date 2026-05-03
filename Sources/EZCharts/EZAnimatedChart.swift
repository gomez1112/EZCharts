import Charts
import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
public struct EZAnimatedChart<Content: ChartContent>: View {
    private let animation: EZChartAnimation
    private let reveal: EZChartReveal
    private let replayToken: AnyHashable?
    private let content: (Double) -> Content

    public init(
        animation: EZChartAnimation = .smooth,
        reveal: EZChartReveal = .none,
        replayToken: AnyHashable? = nil,
        @ChartContentBuilder content: @escaping (Double) -> Content
    ) {
        self.animation = animation
        self.reveal = reveal
        self.replayToken = replayToken
        self.content = content
    }

    public var body: some View {
        EZChartAnimator(animation: animation, replayToken: replayToken) { progress in
            Chart {
                content(progress)
            }
            .modifier(EZChartRevealModifier(reveal: reveal, progress: progress))
        }
    }
}

@available(iOS 16.0, macOS 13.0, *)
private struct EZChartRevealModifier: ViewModifier {
    let reveal: EZChartReveal
    let progress: Double

    @ViewBuilder
    func body(content: Content) -> some View {
        switch reveal {
        case .none:
            content
        case .horizontal:
            content.chartPlotStyle { plotArea in
                plotArea.mask(alignment: .leading) {
                    GeometryReader { proxy in
                        Rectangle()
                            .frame(width: proxy.size.width * EZChartProgress.clamped(progress))
                    }
                }
            }
        }
    }
}
