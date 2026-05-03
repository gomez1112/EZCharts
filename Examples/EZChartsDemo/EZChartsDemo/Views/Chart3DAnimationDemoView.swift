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
                    subtitle: "The same progress helpers drive Chart3D marks.",
                    action: {
                        replayButton
                    }
                ) {
                    EZChartAnimator(
                        animation: EZChartAnimation(duration: 1.6, curve: .easeOut),
                        replayToken: replayToken
                    ) { progress in
                        Chart3D {
                            ForEach(Array(ChartSamples.spatial.enumerated()), id: \.element.id) { index, sample in
                                let pointProgress = EZChartProgress.sequenced(
                                    index: index,
                                    count: ChartSamples.spatial.count,
                                    progress: progress,
                                    overlap: 0.08
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
                    }
                    .frame(height: 320)
                }

                CodeSampleView(
                    lines: [
                        "EZChartAnimator { progress in",
                        "  Chart3D {",
                        "    ForEach(Array(",
                        "      data.enumerated()",
                        "    ),",
                        "            id: \\.element.id) { index, point in",
                        "      let pointProgress =",
                        "        EZChartProgress.sequenced(...)",
                        "      PointMark(",
                        "        x: .value(\"X\", point.x),",
                        "        y: .value(\"Y\",",
                        "          EZChartProgress.scaled(",
                        "            point.y,",
                        "            progress: pointProgress",
                        "          )",
                        "        ),",
                        "        z: .value(\"Z\", point.z)",
                        "      )",
                        "    }",
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
        let animatedRevenue = EZChartProgress.scaled(
            sample.revenue,
            progress: progress
        )

        PointMark(
            x: .value("Acquisition", sample.acquisition),
            y: .value("Revenue", animatedRevenue),
            z: .value("Retention", sample.retention)
        )
        .foregroundStyle(sample.tint)
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
