import SwiftUI

struct MatchMeterCard: View {
    let combinedMatch: CombinedMatch
    let flatmates: [Flatmate]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                // Stacked avatars (you + existing flatmates)
                HStack(spacing: -10) {
                    ForEach(flatmates) { mate in
                        FlatmateAvatar(flatmate: mate, size: 36)
                            .overlay(Circle().strokeBorder(Color.bgBase, lineWidth: 2))
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Combined vibe match")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1)
                        .foregroundStyle(Color.textSecondary)
                    Text(combinedMatch.participants.joined(separator: " + "))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text("\(combinedMatch.score)")
                            .font(.custom("Outfit", size: 28).weight(.heavy))
                        Text("%")
                            .font(.custom("Outfit", size: 16).weight(.bold))
                    }
                    .gradientForeground(.brand)
                    .tracking(-0.5)

                    Text("⚡ \(combinedMatch.summary)")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(Color.accentAmber)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                    Capsule()
                        .fill(LinearGradient.brand)
                        .frame(width: geo.size.width * CGFloat(combinedMatch.score) / 100)
                }
            }
            .frame(height: 5)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [Color.primaryPurple.opacity(0.18), Color.accentAmber.opacity(0.14)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.accentAmber.opacity(0.18))
                .frame(width: 120, height: 120)
                .blur(radius: 28)
                .offset(x: 30, y: -30)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.accentAmber.opacity(0.35), lineWidth: 1)
        )
    }
}
