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
                    subtitle: "Each slice sweeps into place before the next starts.",
                    action: {
                        replayButton
                    }
                ) {
                    EZAnimatedSectorChart(
                        ChartSamples.channels,
                        value: \.value,
                        animation: EZChartAnimation(duration: 1.7, curve: .easeOut),
                        replayToken: replayToken
                    ) { sample in
                        sample.tint
                    }
                    .frame(height: 280)
                }

                CodeSampleView(
                    lines: [
                        "EZAnimatedSectorChart(",
                        "  data,",
                        "  value: \\.value",
                        ") { point in",
                        "  point.color",
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
