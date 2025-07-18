import SwiftUI

struct HeaderView: View {
    let title: String
    
    var body: some View {
        ZStack {
            // Green gradient background
            LinearGradient(gradient: Gradient(colors: [.primaryGreen, .accentGreen]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea(edges: .top)  // Correct syntax to extend to top
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)  // White text
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)  // Centered both horizontally and vertically
        }
        .frame(height: 100)  // Consistent height across all headers
        .overlay(
            Divider()
                .background(Color.white.opacity(0.5))  // Subtle divider at bottom
                .frame(maxHeight: .infinity, alignment: .bottom)
        )
    }
}
