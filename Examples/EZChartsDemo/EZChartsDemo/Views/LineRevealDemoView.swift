import Charts
import EZCharts
import SwiftUI

struct LineRevealDemoView: View {
    @State private var replayToken = UUID()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ChartPanel(
                    title: "Smooth Line Reveal",
                    subtitle: "The chart plot clips from leading edge to trailing edge.",
                    action: {
                        replayButton
                    }
                ) {
                    EZAnimatedChart(
                        animation: EZChartAnimation(duration: 1.1, curve: .easeInOut),
                        reveal: .horizontal,
                        replayToken: replayToken
                    ) { _ in
                        ForEach(ChartSamples.growth) { point in
                            AreaMark(
                                x: .value("Week", point.week),
                                y: .value("Adoption", point.value)
                            )
                            .foregroundStyle(.cyan.opacity(0.18))

                            LineMark(
                                x: .value("Week", point.week),
                                y: .value("Adoption", point.value)
                            )
                            .foregroundStyle(.cyan)
                            .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))

                            PointMark(
                                x: .value("Week", point.week),
                                y: .value("Adoption", point.value)
                            )
                            .foregroundStyle(.cyan)
                        }
                    }
                    .chartYAxisLabel("Adoption")
                    .chartYScale(domain: 0...90)
                    .frame(height: 280)
                }

                CodeSampleView(
                    lines: [
                        "EZAnimatedChart(",
                        "  reveal: .horizontal",
                        ") { _ in",
                        "  LineMark(x: .value(\"Week\", week),",
                        "           y: .value(\"Adoption\", value))",
                        "}"
                    ]
                )
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Line Reveal")
    }

    private var replayButton: some View {
        Button {
            replayToken = UUID()
        } label: {
            Label("Replay", systemImage: "arrow.clockwise")
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    NavigationStack {
        LineRevealDemoView()
    }
}
