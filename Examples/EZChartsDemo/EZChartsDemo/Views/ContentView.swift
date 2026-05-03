import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case bars
    case line

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bars:
            return "Bars"
        case .line:
            return "Line"
        }
    }

    var systemImage: String {
        switch self {
        case .bars:
            return "chart.bar.fill"
        case .line:
            return "chart.xyaxis.line"
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
        }
    }
}

#Preview {
    ContentView()
}
