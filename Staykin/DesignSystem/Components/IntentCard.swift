import SwiftUI

struct IntentCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                // Left accent bar (visible when selected)
                RoundedRectangle(cornerRadius: Radius.full)
                    .fill(isSelected ? LinearGradient.brand : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom))
                    .frame(width: 4)
                    .padding(.vertical, Spacing.sm)

                // Icon
                Text(icon)
                    .font(.system(size: 28))

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom("Outfit", size: 17).weight(.semibold))
                        .foregroundStyle(isSelected ? Color.textPrimary : Color.textPrimary)
                    Text(subtitle)
                        .font(.bodySm)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.primaryViolet : Color.textSecondary)
            }
            .padding(.trailing, Spacing.md)
            .frame(height: ComponentSize.intentCard)
            .background(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(isSelected ? Color.primaryPurple.opacity(0.08) : Color.bgCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .strokeBorder(
                        isSelected ? Color.primaryPurple.opacity(0.5) : Color.cardBorder,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}
