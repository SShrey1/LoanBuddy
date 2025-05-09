import SwiftUI

struct AppStyle {
    static let primaryColor: Color = .blue
    static let secondaryColor = Color(hex: "007AFF")
    static let backgroundColor: Color = Color(.systemBackground)
    static let cardBackground = Color.white
    
    static let shadowColor: Color = Color.black.opacity(0.1)
    static let shadowRadius: CGFloat = 10
    static let cornerRadius: CGFloat = 12
    
    // Add these new styles
    static let gradientColors = [
        Color(hex: "4158D0"),
        Color(hex: "C850C0"),
        Color(hex: "FFCC70")
    ]
    
    struct CardStyle {
        static let background = Color.white
        static let padding: CGFloat = 20
        static let spacing: CGFloat = 16
        
        static var shadow: some View {
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .fill(Color.white)
                .shadow(color: AppStyle.shadowColor, radius: 5)
        }
    }
    
    struct TextStyle {
        static let title: Font = .title
        static let heading: Font = .title2
        static let body: Font = .body
        static let caption: Font = .caption
    }
}

// Custom Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppStyle.TextStyle.heading)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppStyle.primaryColor)
            .cornerRadius(AppStyle.cornerRadius)
            .shadow(color: AppStyle.shadowColor, radius: 5, y: 2)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Custom TextField Style
struct AppTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(AppStyle.cornerRadius)
            .shadow(color: AppStyle.shadowColor, radius: 4)
    }
}

// Add this new button style
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppStyle.TextStyle.body)
            .foregroundColor(AppStyle.primaryColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(AppStyle.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                    .stroke(AppStyle.primaryColor, lineWidth: 1)
            )
            .shadow(color: AppStyle.shadowColor, radius: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Helper for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 