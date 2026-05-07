import SwiftUI

struct VibeTile: View {
    let emoji: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected
                              ? AnyShapeStyle(LinearGradient.brand)
                              : AnyShapeStyle(Color.bgCard))
                        .frame(width: 88, height: 88)
                        .shadow(
                            color: isSelected ? Color.primaryPurple.opacity(0.22) : .clear,
                            radius: 12, x: 0, y: 8
                        )
                        .overlay(
                            Circle().strokeBorder(
                                isSelected ? Color.clear : Color.cardBorder,
                                lineWidth: 1
                            )
                        )

                    Text(emoji)
                        .font(.system(size: 40))
                        .saturation(isSelected ? 1.0 : 0.85)
                }
                .overlay(alignment: .topTrailing) {
                    if isSelected {
                        ZStack {
                            Circle().fill(Color.bgBase).frame(width: 26, height: 26)
                            Circle().fill(Color.accentAmber).frame(width: 20, height: 20)
                            Text("✓")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundStyle(.white)
                        }
                        .offset(x: 2, y: -2)
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: isSelected)

                Text(label)
                    .font(.custom("Outfit", size: 13).weight(isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .lineSpacing(1)
            }
        }
        .buttonStyle(.plain)
    }
}
