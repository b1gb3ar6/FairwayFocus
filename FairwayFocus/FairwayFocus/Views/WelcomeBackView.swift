import SwiftUI

struct WelcomeBackView: View {
    @Binding var showWelcomeBack: Bool
    @AppStorage("lastVisitTimestamp") private var lastVisitTimestamp: Double = 0  // Use timestamp instead of Date
    
    private var lastVisitDate: Date? {
        lastVisitTimestamp > 0 ? Date(timeIntervalSince1970: lastVisitTimestamp) : nil
    }
    
    private var daysSinceLastVisit: Int {
        if let lastDate = lastVisitDate {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: lastDate, to: Date())
            return components.day ?? 0
        }
        return 0
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 20))  // Rounded edges like app icon
                .padding(.top, 50)
            
            Text("Welcome Back to Fairway Focus!")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.primaryText)
            
            Text("It's been \(daysSinceLastVisit) days since your last session. Take a few practice swings to warm up, then dive into today's test to refine your accuracy and consistency.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondaryText)
                .padding(.horizontal, 20)
            
            Text("Remember: Consistent practice leads to lower scores—focus on alignment and tempo for best results.")
                .font(.subheadline)
                .italic()
                .foregroundColor(.primaryGreen)
                .padding(.horizontal, 20)
            
            Button("Get Started") {
                lastVisitTimestamp = Date().timeIntervalSince1970  // Update last visit
                showWelcomeBack = false  // Dismiss welcome back
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.primaryGreen)
            .cornerRadius(10)
            .padding(.bottom, 50)
        }
        .background(Color.appBackground)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            if lastVisitTimestamp == 0 {
                lastVisitTimestamp = Date().timeIntervalSince1970  // Set if first time here
            }
        }
    }
}
