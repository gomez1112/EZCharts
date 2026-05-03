import Charts
import EZCharts
import SwiftUI

struct SectorAnimationDemoView: View {
    @State private var replayToken = UUID()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ChartPanel(
                    title: "Sequenced Sectors",
                    subtitle: "Each sector expands into its final share.",
                    action: {
                        replayButton
                    }
                ) {
                    EZAnimatedChart(
                        animation: EZChartAnimation(duration: 1.7, curve: .easeOut),
                        replayToken: replayToken
                    ) { progress in
                        ForEach(Array(ChartSamples.channels.enumerated()), id: \.element.id) { index, sample in
                            let sectorProgress = EZChartProgress.sequenced(
                                index: index,
                                count: ChartSamples.channels.count,
                                progress: progress,
                                overlap: 0.08
                            )

                            SectorMark(
                                angle: .value("Share", sample.value),
                                innerRadius: .ratio(0.52),
                                outerRadius: .ratio(0.52 + (0.48 * sectorProgress)),
                                angularInset: 2
                            )
                            .cornerRadius(5)
                            .foregroundStyle(sample.tint)
                            .opacity(sectorProgress)
                        }
                    }
                    .chartLegend(.hidden)
                    .frame(height: 280)
                }

                CodeSampleView(
                    lines: [
                        "EZAnimatedChart { progress in",
                        "  ForEach(data.enumerated(),",
                        "          id: \\.element.id) { index, point in",
                        "    let sectorProgress =",
                        "      EZChartProgress.sequenced(",
                        "        index: index,",
                        "        count: data.count,",
                        "        progress: progress",
                        "      )",
                        "    SectorMark(",
                        "      angle: .value(\"Share\", point.value),",
                        "      outerRadius: .ratio(",
                        "        0.52 + 0.48 * sectorProgress",
                        "      )",
                        "    )",
                        "    .opacity(sectorProgress)",
                        "  }",
                        "}"
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
        SectorAnimationDemoView()
    }
}
