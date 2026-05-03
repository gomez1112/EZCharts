import SwiftUI

struct RevenueSample: Identifiable {
    let id = UUID()
    let month: String
    let value: Double
    let tint: Color
}

struct GrowthPoint: Identifiable {
    let id = UUID()
    let week: String
    let value: Double
}

enum ChartSamples {
    static let revenue: [RevenueSample] = [
        RevenueSample(month: "Jan", value: 34, tint: .teal),
        RevenueSample(month: "Feb", value: 42, tint: .blue),
        RevenueSample(month: "Mar", value: 58, tint: .indigo),
        RevenueSample(month: "Apr", value: 50, tint: .orange),
        RevenueSample(month: "May", value: 76, tint: .pink),
        RevenueSample(month: "Jun", value: 88, tint: .green)
    ]

    static let growth: [GrowthPoint] = [
        GrowthPoint(week: "W1", value: 12),
        GrowthPoint(week: "W2", value: 18),
        GrowthPoint(week: "W3", value: 26),
        GrowthPoint(week: "W4", value: 31),
        GrowthPoint(week: "W5", value: 45),
        GrowthPoint(week: "W6", value: 53),
        GrowthPoint(week: "W7", value: 68),
        GrowthPoint(week: "W8", value: 74)
    ]
}
