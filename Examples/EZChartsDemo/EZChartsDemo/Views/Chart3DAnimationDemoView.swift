import Charts
import EZCharts
import SwiftUI

@available(iOS 26.0, *)
struct Chart3DAnimationDemoView: View {
    @State private var replayToken = UUID()
    @State private var pose = Chart3DPose(
        azimuth: .degrees(35),
        inclination: .degrees(18)
    )

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ChartPanel(
                    title: "Sequenced 3D Points",
                    subtitle: "A dedicated 3D wrapper drives the marks frame by frame.",
                    action: {
                        replayButton
                    }
                ) {
                    EZAnimatedChart3D(
                        animation: EZChartAnimation(duration: 2.2, curve: .easeOut),
                        replayToken: replayToken
                    ) { progress in
                        ForEach(Array(ChartSamples.spatial.enumerated()), id: \.element.id) { index, sample in
                            let pointProgress = EZChart3DProgress.sequenced(
                                index: index,
                                count: ChartSamples.spatial.count,
                                progress: progress,
                                overlap: 0.05
                            )
                            animatedPointMark(for: sample, progress: pointProgress)
                        }
                    }
                    .chart3DPose($pose)
                    .chartXAxisLabel("Acquisition")
                    .chartYAxisLabel("Revenue")
                    .chartZAxisLabel("Retention")
                    .chartXScale(domain: 0...100, range: -0.5...0.5)
                    .chartYScale(domain: 0...100, range: -0.5...0.5)
                    .chartZScale(domain: 0...100, range: -0.5...0.5)
                    .frame(height: 320)
                }

                CodeSampleView(
                    lines: [
                        "EZAnimatedChart3D { progress in",
                        "  ForEach(data) { point in",
                        "    PointMark(",
                        "      x: .value(\"X\", point.x),",
                        "      y: .value(\"Y\",",
                        "        EZChart3DProgress.scaled(",
                        "          point.y,",
                        "          progress: progress",
                        "        )",
                        "      ),",
                        "      z: .value(\"Z\", point.z)",
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

    @Chart3DContentBuilder
    private func animatedPointMark(
        for sample: SpatialSample,
        progress: Double
    ) -> some Chart3DContent {
        let animatedRevenue = EZChart3DProgress.scaled(
            sample.revenue,
            progress: progress
        )
        let symbolSize = CGFloat(0.01 + (0.065 * progress))

        PointMark(
            x: .value("Acquisition", sample.acquisition),
            y: .value("Revenue", animatedRevenue),
            z: .value("Retention", sample.retention)
        )
        .symbolSize(symbolSize)
        .foregroundStyle(sample.tint.opacity(progress))
    }
}

struct Chart3DUnavailableView: View {
    var body: some View {
        ContentUnavailableView(
            "Chart3D requires iOS 26",
            systemImage: "cube.transparent",
            description: Text("Run the demo on an iOS 26 simulator to view this chart.")
        )
        .navigationTitle("EZCharts")
    }
}
