import SwiftUI

enum Theme {
    static let gradient = LinearGradient(
        colors: [
            Color(hex: "4158D0"),
            Color(hex: "C850C0"),
            Color(hex: "FFCC70")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let meshGradient = MeshGradient()
    
    static let breathingAnimation = Animation.easeInOut(duration: 4.0)
    
    static let cardBackground = Color(UIColor.systemBackground)
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
}

struct MeshGradient: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "4158D0").opacity(0.5))
                .frame(width: 300)
                .blur(radius: 20)
                .offset(x: animate ? 50 : -50, y: animate ? -30 : 30)
            
            Circle()
                .fill(Color(hex: "C850C0").opacity(0.5))
                .frame(width: 300)
                .blur(radius: 20)
                .offset(x: animate ? -50 : 50, y: animate ? 30 : -30)
            
            Circle()
                .fill(Color(hex: "FFCC70").opacity(0.5))
                .frame(width: 300)
                .blur(radius: 20)
                .offset(x: animate ? 30 : -30, y: animate ? 50 : -50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

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