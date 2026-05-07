import SwiftUI

struct FlatmateListRow: View {
    let flatmate: Flatmate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                FlatmateAvatar(flatmate: flatmate, size: 48)
                    .overlay(
                        Circle()
                            .strokeBorder(LinearGradient.brand, lineWidth: 2)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("\(flatmate.name), \(flatmate.age)")
                            .font(.custom("Outfit", size: 14).weight(.bold))
                            .foregroundStyle(Color.textPrimary)
                            .lineLimit(1)

                        Text("⚡ \(flatmate.matchPct)%")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(Color.accentAmber)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Color.accentAmber.opacity(0.18))
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(Color.accentAmber.opacity(0.4), lineWidth: 1))
                    }

                    Text(flatmate.job)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        ForEach(Array(flatmate.displayTags.prefix(3).enumerated()), id: \.offset) { _, tag in
                            Text(tag)
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color(hex: "C4B5FD"))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Color.primaryPurple.opacity(0.12))
                                .clipShape(Capsule())
                                .overlay(Capsule().strokeBorder(Color.primaryPurple.opacity(0.25), lineWidth: 1))
                                .lineLimit(1)
                                .fixedSize()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .black, location: 0.7),
                                .init(color: .clear, location: 1)
                            ],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(12)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
