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
    
    static let glassEffect = AnyShapeStyle(.ultraThinMaterial)
    
    static let animationDurations = AnimationDurations()
    static let springAnimation = Spring()
    
    static let shadows = Shadows()
    static let dimensions = Dimensions()
    
    struct AnimationDurations {
        let short = 0.3
        let medium = 0.6
        let long = 1.0
        let breathing = 4.0
    }
    
    struct Spring {
        let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.25)
        let smooth = Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.25)
        let tight = Animation.spring(response: 0.3, dampingFraction: 0.9, blendDuration: 0.25)
    }
    
    struct Shadows {
        let small = Shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        let medium = Shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        let large = Shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 6)
    }
    
    struct Dimensions {
        let cornerRadius = CornerRadius()
        let padding = Padding()
    }
    
    struct CornerRadius {
        let small: CGFloat = 8
        let medium: CGFloat = 15
        let large: CGFloat = 25
    }
    
    struct Padding {
        let small: CGFloat = 8
        let medium: CGFloat = 16
        let large: CGFloat = 24
    }
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

struct GlassMorphicCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Theme.dimensions.padding.medium)
            .background(Theme.glassEffect)
            .clipShape(RoundedRectangle(cornerRadius: Theme.dimensions.cornerRadius.medium))
            .shadow(radius: Theme.shadows.medium.radius)
    }
}

struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1)
            .opacity(isPulsing ? 0.8 : 1)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}

struct FloatingEffect: ViewModifier {
    @State private var isFloating = false
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -5 : 5)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
                ) {
                    isFloating = true
                }
            }
    }
}

extension View {
    func glassMorphic() -> some View {
        modifier(GlassMorphicCard())
    }
    
    func pulsingAnimation() -> some View {
        modifier(PulseAnimation())
    }
    
    func floating() -> some View {
        modifier(FloatingEffect())
    }
} 