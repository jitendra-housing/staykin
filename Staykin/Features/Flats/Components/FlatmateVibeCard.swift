import SwiftUI

// Mirrors onboarding's VibeCard but driven by a Flatmate. Role badge
// flips per design (THEIR VIBE / FLATMATE / HOST) and the gradient
// uses the flatmate's avatar hues.
struct FlatmateVibeCard: View {
    let flatmate: Flatmate

    private var gradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hue: flatmate.avatarHue / 360,  saturation: 0.62, brightness: 0.62),
                Color(hue: flatmate.avatarHue2 / 360, saturation: 0.62, brightness: 0.70),
                Color(hex: "C4B5FD")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var lookingForHeader: String {
        flatmate.role == .poster ? "Looking for in flatmates" : "Looking for"
    }

    private var tagRows: [[String]] {
        let tags = flatmate.displayTags
        guard !tags.isEmpty else { return [] }
        let mid = (tags.count + 1) / 2
        return [Array(tags.prefix(mid)), Array(tags.dropFirst(mid))]
    }

    var body: some View {
        ZStack {
            gradient

            // Decorative blurred blobs
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 200, height: 200)
                .blur(radius: 40)
                .offset(x: 130, y: -160)
            Circle()
                .fill(Color.accentAmber.opacity(0.3))
                .frame(width: 240, height: 240)
                .blur(radius: 60)
                .offset(x: -100, y: 180)

            VStack(spacing: 0) {
                // Top: Staykin + role badge
                HStack {
                    Text("Staykin")
                        .font(.custom("Outfit", size: 14).weight(.heavy))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(flatmate.role.badgeText)
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)

                Spacer(minLength: 0)

                // Avatar + name + subtitle + match pct
                VStack(spacing: 8) {
                    avatar

                    VStack(spacing: 2) {
                        Text("\(flatmate.name), \(flatmate.age)")
                            .font(.custom("Outfit", size: 20).weight(.bold))
                            .foregroundStyle(.white)
                        Text(flatmate.job)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))
                    }

                    Text("⚡ \(flatmate.matchPct)% vibe match")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(Color(hex: "FCD34D"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 22)

                Spacer(minLength: 0)

                // 2-row tag strip with edge-fade mask
                if !tagRows.isEmpty {
                    VStack(spacing: 5) {
                        ForEach(Array(tagRows.enumerated()), id: \.offset) { _, row in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 5) {
                                    ForEach(row, id: \.self) { tag in
                                        Text(tag)
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                            .padding(.horizontal, 9)
                                            .padding(.vertical, 4)
                                            .background(Color.white.opacity(0.25))
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .black, location: 0.05),
                                .init(color: .black, location: 0.95),
                                .init(color: .clear, location: 1)
                            ],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                }

                // Looking-for footer
                lookingForFooter
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)
            }
        }
        .frame(height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.primaryPurple.opacity(0.35), radius: 30, x: 0, y: 20)
    }

    // White-to-gray avatar with emoji centered (matches onboarding's VibeCard)
    private var avatar: some View {
        ZStack {
            LinearGradient(
                colors: [.white, Color(hex: "E0E0E0")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            if let emoji = flatmate.emoji {
                Text(emoji).font(.system(size: 30))
            }
        }
        .frame(width: 76, height: 76)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(Color.white.opacity(0.4), lineWidth: 4))
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)
    }

    private var lookingForFooter: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(lookingForHeader.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.bottom, 4)

            ForEach(Array(flatmate.lookingFor.enumerated()), id: \.offset) { i, row in
                if i > 0 {
                    Rectangle()
                        .fill(.white.opacity(0.10))
                        .frame(height: 1)
                        .padding(.vertical, 4)
                }
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(row.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer(minLength: 0)
                    Text(row.value)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
