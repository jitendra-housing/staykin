import SwiftUI

// MARK: - Typography Tokens
// Font: Outfit variable font (Outfit-Variable.ttf, family name "Outfit", wght axis 100–900)
// iOS 17+ variable font support: Font.custom("Outfit", size:).weight() applies the wght axis.

extension Font {
    static let display  = Font.custom("Outfit", size: 32).weight(.bold)        // Screen titles
    static let heading1 = Font.custom("Outfit", size: 24).weight(.semibold)    // Section titles
    static let heading2 = Font.custom("Outfit", size: 20).weight(.semibold)    // Card titles
    static let bodyLg   = Font.custom("Outfit", size: 16).weight(.regular)     // Body text
    static let bodySm   = Font.custom("Outfit", size: 14).weight(.regular)     // Secondary body
    static let caption1 = Font.custom("Outfit", size: 12).weight(.medium)      // Tags, labels
    static let buttonLg = Font.custom("Outfit", size: 16).weight(.semibold)    // CTA buttons
}
