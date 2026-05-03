import SwiftUI

struct ChartPanel<Action: View, Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let action: Action
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.weight(.semibold))
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 12)

                action
            }

            content
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct CodeSampleView: View {
    let lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recipe")
                .font(.headline)

            VStack(alignment: .leading, spacing: 5) {
                ForEach(lines, id: \.self) { line in
                    Text(line)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ChartPanel(
        title: "Preview",
        subtitle: "Panel layout",
        action: {
            Button("Replay") {}
        }
    ) {
        Text("Chart goes here")
            .frame(maxWidth: .infinity, minHeight: 180)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
