import SwiftUI

enum PillVariant {
    case pill   // Lifestyle chips — bgCard bg when unselected
    case tag    // Interest tags — tinted purple bg when unselected
}

struct SelectablePill: View {
    let label: String
    let isSelected: Bool
    var variant: PillVariant = .pill
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption1)
                .foregroundStyle(foregroundColor)
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background(backgroundColor)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    private var foregroundColor: Color {
        isSelected ? Color(hex: "E9D5FF") : (variant == .tag ? Color(hex: "C4B5FD") : Color.textSecondary)
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.primaryPurple.opacity(0.18)
        }
        return variant == .tag ? Color.primaryPurple.opacity(0.08) : Color.bgCard
    }

    private var borderColor: Color {
        if isSelected {
            return Color.primaryPurple.opacity(0.5)
        }
        return variant == .tag ? Color.primaryPurple.opacity(0.22) : Color.cardBorder
    }
}
