import SwiftUI

// MARK: - Color Tokens
// Source: Staykin design spec (subtle purple→violet palette)

extension Color {
    // Backgrounds
    static let bgBase    = Color(hex: "0D0D0D")   // App background
    static let bgCard    = Color(hex: "18182A")   // Card surfaces
    static let bgSheet   = Color(hex: "141420")   // Bottom sheets, modals

    // Brand — narrow purple→soft-violet (low chroma)
    static let primaryPurple = Color(hex: "8B5CF6")  // Gradient start, CTAs
    static let primaryViolet = Color(hex: "A78BFA")  // Gradient end

    // Accent
    static let accentAmber = Color(hex: "D4A574")    // Muted warm tan (vibe score, badges)

    // Text
    static let textPrimary   = Color.white
    static let textSecondary = Color(hex: "9A9AAB")
    static let textDisabled  = Color(hex: "4A4A5A")

    // Semantic
    static let success     = Color(hex: "10B981")   // Match, confirmed
    static let destructive = Color(hex: "EF4444")   // Skip / dislike

    // Borders
    static var cardBorder: Color { .white.opacity(0.06) }
    static var divider: Color    { .white.opacity(0.06) }

    // MARK: - Hex initialiser
    init(hex: String) {
        var str = hex.trimmingCharacters(in: .alphanumerics.inverted)
        if str.count == 3 {
            str = str.map { "\($0)\($0)" }.joined()
        }
        var value: UInt64 = 0
        Scanner(string: str).scanHexInt64(&value)
        self.init(
            .sRGB,
            red:     Double((value >> 16) & 0xFF) / 255,
            green:   Double((value >>  8) & 0xFF) / 255,
            blue:    Double( value        & 0xFF) / 255,
            opacity: str.count == 8 ? Double((value >> 24) & 0xFF) / 255 : 1
        )
    }
}
