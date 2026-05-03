import Charts
import EZCharts
import SwiftUI

struct BarAnimationDemoView: View {
    @State private var replayToken = UUID()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ChartPanel(
                    title: "Sequenced Bar Growth",
                    subtitle: "Each bar expands before the next begins.",
                    action: {
                        replayButton
                    }
                ) {
                    EZAnimatedChart(
                        animation: EZChartAnimation(duration: 1.5, curve: .easeOut),
                        replayToken: replayToken
                    ) { progress in
                        ForEach(Array(ChartSamples.revenue.enumerated()), id: \.element.id) { index, sample in
                            BarMark(
                                x: .value("Month", sample.month),
                                y: .value(
                                    "Revenue",
                                    EZChartProgress.scaled(
                                        sample.value,
                                        progress: EZChartProgress.sequenced(
                                            index: index,
                                            count: ChartSamples.revenue.count,
                                            progress: progress,
                                            overlap: 0.08
                                        )
                                    )
                                )
                            )
                            .foregroundStyle(sample.tint)
                            .cornerRadius(7)
                        }
                    }
                    .chartYAxisLabel("Revenue")
                    .ezChartYScale(for: ChartSamples.revenue.map(\.value))
                    .frame(height: 280)
                }

                CodeSampleView(
                    lines: [
                        "EZAnimatedChart { progress in",
                        "  ForEach(data) { point in",
                        "    BarMark(",
                        "      x: .value(\"Month\", point.month),",
                        "      y: .value(\"Revenue\",",
                        "        EZChartProgress.scaled(",
                        "          point.value,",
                        "          progress: EZChartProgress",
                        "            .sequenced(...)",
                        "        )",
                        "      )",
                        "    )",
                        "  }",
                        "}",
                        ".ezChartYScale(",
                        "  for: data.map(\\.value)",
                        ")"
                    ]
                )
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("EZCharts")
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
        BarAnimationDemoView()
    }
}
