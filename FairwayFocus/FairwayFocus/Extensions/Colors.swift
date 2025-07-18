import SwiftUI
import Foundation  // For Scanner compatibility

extension Color {
    static let primaryGreen = Color(hex: "#006400") // Dark green for buttons and accents
    static let accentGreen = Color(hex: "#90EE90") // Light green for highlights
    static let appBackground = Color(hex: "#F5F5F5") // Light gray background
    static let primaryText = Color(hex: "#333333") // Dark text
    static let secondaryText = Color(hex: "#777777") // Lighter text
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        if let value = UInt64(hex, radix: 16) {  // Modern radix parsing, avoids Scanner deprecation
            int = value
        }
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
