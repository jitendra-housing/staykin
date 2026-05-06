import CoreGraphics

// MARK: - Spacing (8pt grid)

enum Spacing {
    static let xxs:  CGFloat = 4
    static let xs:   CGFloat = 8
    static let sm:   CGFloat = 12
    static let md:   CGFloat = 16
    static let lg:   CGFloat = 20
    static let xl:   CGFloat = 24
    static let xxl:  CGFloat = 32
    static let xxxl: CGFloat = 40
    static let huge: CGFloat = 48
    static let max:  CGFloat = 64

    // Common layout constants
    static let screenHPad:   CGFloat = 24  // Horizontal screen padding
    static let tabBarHeight: CGFloat = 80  // Includes home indicator area
}

// MARK: - Border Radius

enum Radius {
    static let sm:   CGFloat = 8    // Chips, small tags
    static let md:   CGFloat = 12   // Pills, input fields
    static let lg:   CGFloat = 20   // Cards
    static let xl:   CGFloat = 28   // Bottom sheets, modals
    static let full: CGFloat = 999  // Avatars, circular buttons
}

// MARK: - Component Sizes

enum ComponentSize {
    static let buttonHeight:  CGFloat = 56   // Primary / secondary buttons
    static let inputHeight:   CGFloat = 48   // Text fields
    static let tabBarHeight:  CGFloat = 80
    static let intentCard:    CGFloat = 80   // Intent selection cards
    static let avatarLg:      CGFloat = 96   // Profile avatar
    static let avatarMd:      CGFloat = 48   // List rows
    static let avatarSm:      CGFloat = 32   // Chips
    static let actionButton:  CGFloat = 64   // Like / Skip circles
}
