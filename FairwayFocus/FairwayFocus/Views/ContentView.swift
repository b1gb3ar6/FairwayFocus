import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            BagSetupView()
                .tabItem {
                    Label {
                        Text("Bag Setup")
                    } icon: {
                        Image("golf_bag_icon")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                    }
                }
                .tag(0)
            
            TestView()
                .tabItem {
                    Label("Test", systemImage: "target")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
            
            ClubDataView()  // Replaced placeholder with ClubDataView
                .tabItem {
                    Label("Club Data", systemImage: "chart.bar.xaxis")  // Icon for data/chart
                }
                .tag(3)
        }
        .accentColor(.primaryGreen) // Custom color for tabs
    }
}

#Preview {
    ContentView()
}
