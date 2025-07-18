import SwiftUI

@main
struct FairwayFocusApp: App {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @AppStorage("userBagData") private var userBagData: Data = Data()  // Store as JSON Data
    
    private var userBag: [String] {
        if let bag = try? JSONDecoder().decode([String].self, from: userBagData) {
            return bag
        }
        return []
    }
    
    @State private var showOnboarding: Bool = false
    @State private var showWelcomeBack: Bool = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showOnboarding {
                    OnboardingView(hasLaunchedBefore: $hasLaunchedBefore, showOnboarding: $showOnboarding)
                } else if showWelcomeBack {
                    WelcomeBackView(showWelcomeBack: $showWelcomeBack)
                } else {
                    ContentView()
                }
            }
            .onAppear {
                if !hasLaunchedBefore || userBag.isEmpty {
                    showOnboarding = true
                } else {
                    showWelcomeBack = true
                }
            }
        }
    }
}
