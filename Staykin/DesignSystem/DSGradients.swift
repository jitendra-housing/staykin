import SwiftUI

// MARK: - Gradient Tokens
// Named with "brand" prefix to avoid conflicts with SwiftUI's HierarchicalShapeStyle.

extension LinearGradient {
    /// Purple → violet — primary brand gradient (135°)
    static let brand = LinearGradient(
        colors: [.primaryPurple, .primaryViolet],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Dark card background (180°)
    static let cardBg = LinearGradient(
        colors: [Color(hex: "1A1A2E"), Color(hex: "0D0D16")],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Image overlay — transparent → near-black (180°)
    static let imageOverlay = LinearGradient(
        colors: [.clear, Color.black.opacity(0.85)],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension RadialGradient {
    /// Subtle background glow used on match / splash screens
    static let backgroundGlow = RadialGradient(
        colors: [Color.primaryPurple.opacity(0.15), .clear],
        center: .center,
        startRadius: 0,
        endRadius: 250
    )
}

// MARK: - Gradient Text Modifier

struct GradientTextModifier: ViewModifier {
    var gradient: LinearGradient = .brand

    func body(content: Content) -> some View {
        content.foregroundStyle(gradient)
    }
}

extension View {
    func gradientForeground(_ gradient: LinearGradient = .brand) -> some View {
        modifier(GradientTextModifier(gradient: gradient))
    }
}
