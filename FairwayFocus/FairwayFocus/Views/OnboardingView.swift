import SwiftUI

struct OnboardingView: View {
    @Binding var hasLaunchedBefore: Bool
    @Binding var showOnboarding: Bool  // Added binding to dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 20))  // Rounded edges like app icon
                .padding(.top, 50)
            
            Text("Welcome to Fairway Focus")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
            
            Text("Your ultimate golf companion for tracking shots, analyzing performance, and improving consistency. Get insights like pro tools to hit more fairways and lower your scores.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondaryText)
                .padding(.horizontal, 20)
            
            Text("Start by adding clubs to your bag, then run tests at the range to build data and track progress.")
                .font(.subheadline)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(.primaryGreen)
                .padding(.horizontal, 20)
            
            Button("Begin Your Journey") {
                hasLaunchedBefore = true
                showOnboarding = false  // Dismiss onboarding
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primaryGreen)
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.appBackground)
    }
}
