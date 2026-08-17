import Charts
import SwiftUI

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
        EZChartProgressPlayback(animation: animation, replayToken: replayToken) { progress in
            Chart {
                content(progress)
            }
            .modifier(EZChartRevealModifier(reveal: reveal, progress: progress))
        }
    }
}

private struct EZChartRevealModifier: ViewModifier {
    let reveal: EZChartReveal
    let progress: Double

    @ViewBuilder
    func body(content: Content) -> some View {
        if reveal == .none {
            content
        } else {
            #if os(watchOS)
            content.mask {
                EZChartRevealMask(reveal: reveal, progress: progress)
            }
            #else
            content.chartPlotStyle { plotArea in
                plotArea.mask {
                    EZChartRevealMask(reveal: reveal, progress: progress)
                }
            }
            #endif
        }
    }
}

private struct EZChartRevealMask: View {
    let reveal: EZChartReveal
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            switch reveal.kind {
            case .none:
                Rectangle()
            case .horizontal:
                Rectangle()
                    .frame(width: proxy.size.width * EZChartProgress.clamped(progress))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            case .vertical:
                Rectangle()
                    .frame(height: proxy.size.height * EZChartProgress.clamped(progress))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            case .radial:
                Circle()
                    .scaleEffect(EZChartProgress.clamped(progress))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
