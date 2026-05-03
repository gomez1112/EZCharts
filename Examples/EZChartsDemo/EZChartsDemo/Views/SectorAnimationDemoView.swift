import Charts
import EZCharts
import SwiftUI

struct SectorAnimationDemoView: View {
    @State private var replayToken = UUID()

    var body: some View {
        let sectorRanges = EZChartProgress.sectorRanges(for: ChartSamples.channels.map(\.value))

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ChartPanel(
                    title: "Sequenced Sectors",
                    subtitle: "Each slice sweeps into place before the next starts.",
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
                            let revealedRange = EZChartProgress.revealedRange(
                                sectorRanges[index],
                                progress: sectorProgress
                            )

                            SectorMark(
                                angle: .value("Share", revealedRange),
                                innerRadius: .ratio(0.52),
                                outerRadius: .ratio(1),
                                angularInset: 2
                            )
                            .cornerRadius(5)
                            .foregroundStyle(sample.tint)
                        }
                    }
                    .chartLegend(.hidden)
                    .frame(height: 280)
                }

                CodeSampleView(
                    lines: [
                        "let ranges =",
                        "  EZChartProgress.sectorRanges(",
                        "    for: data.map(\\.value)",
                        "  )",
                        "EZAnimatedChart { progress in",
                        "  ForEach(Array(",
                        "    data.enumerated()",
                        "  ),",
                        "          id: \\.element.id) { index, point in",
                        "    let sectorProgress =",
                        "      EZChartProgress.sequenced(",
                        "        index: index,",
                        "        count: data.count,",
                        "        progress: progress",
                        "      )",
                        "    let finalRange = ranges[index]",
                        "    let revealedRange =",
                        "      EZChartProgress.revealedRange(",
                        "        finalRange,",
                        "        progress: sectorProgress",
                        "      )",
                        "    SectorMark(",
                        "      angle: .value(",
                        "        \"Share\", revealedRange",
                        "      ),",
                        "      innerRadius: .ratio(0.52)",
                        "    )",
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
