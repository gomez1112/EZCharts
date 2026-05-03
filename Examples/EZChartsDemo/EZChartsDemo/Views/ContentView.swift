import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case bars
    case line
    case sectors

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bars:
            return "Bars"
        case .line:
            return "Line"
        case .sectors:
            return "Sectors"
        }
    }

    var systemImage: String {
        switch self {
        case .bars:
            return "chart.bar.fill"
        case .line:
            return "chart.xyaxis.line"
        case .sectors:
            return "chart.pie.fill"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .bars

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                BarAnimationDemoView()
            }
            .tabItem {
                Label(AppTab.bars.title, systemImage: AppTab.bars.systemImage)
            }
            .tag(AppTab.bars)

            NavigationStack {
                LineRevealDemoView()
            }
            .tabItem {
                Label(AppTab.line.title, systemImage: AppTab.line.systemImage)
            }
            .tag(AppTab.line)

            NavigationStack {
                SectorAnimationDemoView()
            }
            .tabItem {
                Label(AppTab.sectors.title, systemImage: AppTab.sectors.systemImage)
            }
            .tag(AppTab.sectors)
        }
    }
}

#Preview {
    ContentView()
}
