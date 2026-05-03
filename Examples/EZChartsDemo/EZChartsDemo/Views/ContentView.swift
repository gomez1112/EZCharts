import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case bars
    case line
    case sectors
    case spatial

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bars:
            return "Bars"
        case .line:
            return "Line"
        case .sectors:
            return "Sectors"
        case .spatial:
            return "3D"
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
        case .spatial:
            return "cube.fill"
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

            NavigationStack {
                if #available(iOS 26.0, *) {
                    Chart3DAnimationDemoView()
                } else {
                    Chart3DUnavailableView()
                }
            }
            .tabItem {
                Label(AppTab.spatial.title, systemImage: AppTab.spatial.systemImage)
            }
            .tag(AppTab.spatial)
        }
    }
}

#Preview {
    ContentView()
}
