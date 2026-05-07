import SwiftUI

struct VibeCardScreen: View {
    let onFinish: () -> Void
    let onBack: () -> Void

    @Environment(OnboardingData.self) private var data

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.bgCard)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(Color.cardBorder, lineWidth: 1))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your vibe card is ready! 🪩")
                        .font(.heading2)
                        .foregroundStyle(Color.textPrimary)
                    Text("Share it everywhere ✨")
                        .font(.caption1)
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, Spacing.screenHPad)
            .padding(.top, 24)
            .padding(.bottom, 12)

            ScrollView {
                VStack(spacing: 0) {
                    VibeCard(data: data)
                        .padding(.top, 20)

                    HStack(spacing: 6) {
                        Text("✓").font(.system(size: 12, weight: .heavy))
                        Text("Onboarding complete")
                            .font(.caption1.weight(.bold))
                    }
                    .foregroundStyle(Color.success)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.success.opacity(0.15))
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(Color.success.opacity(0.4), lineWidth: 1))
                    .padding(.top, 28)

                    PrimaryButton(title: "Start searching ✨", action: onFinish)
                        .padding(.horizontal, Spacing.screenHPad)
                        .padding(.top, 14)
                        .padding(.bottom, 32)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Vibe Card

private struct VibeCard: View {
    let data: OnboardingData

    private static let cardWidth: CGFloat = 320
    private static let cardHeight: CGFloat = 480

    private var vibeChips: [String] {
        data.vibePrefs
            .sorted()
            .compactMap(VibePref.find(by:))
            .map { "\($0.emoji) \($0.label)" }
    }

    private var nameAndAge: String {
        let firstName = data.name.split(separator: " ").first.map(String.init)
            ?? (data.name.isEmpty ? "You" : data.name)
        if let age = data.age { return "\(firstName), \(age)" }
        return firstName
    }

    private var occupationCity: String {
        let occupationName = data.occupation.flatMap { Occupation.find(by: $0)?.name } ?? ""
        return [occupationName, data.city].filter { !$0.isEmpty }.joined(separator: " · ")
    }

    private var budgetText: String {
        "₹\(Int(data.budgetMin / 1000))–\(Int(data.budgetMax / 1000))K /mo"
    }

    private var typeText: String {
        BHK.all.filter { data.bhk.contains($0.id) }.map(\.label).joined(separator: " · ")
    }

    private var areasText: String {
        data.areas
            .sorted()
            .compactMap(Area.find(by:))
            .prefix(3)
            .map(\.name)
            .joined(separator: ", ")
    }

    var body: some View {
        ZStack {
            // Card gradient (3-stop, slightly different from .brand)
            LinearGradient(
                colors: [Color(hex: "8B5CF6"), Color(hex: "A78BFA"), Color(hex: "C4B5FD")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative blurred deco circles
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

            // Content
            VStack(spacing: 0) {
                // Top row
                HStack {
                    Text("Staykin")
                        .font(.custom("Outfit", size: 20).weight(.heavy))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("MY VIBE")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)

                // Avatar + name
                Spacer(minLength: 0)
                VStack(spacing: 12) {
                    avatarView
                    VStack(spacing: 2) {
                        Text(nameAndAge)
                            .font(.custom("Outfit", size: 26).weight(.bold))
                            .foregroundStyle(.white)
                        if !occupationCity.isEmpty {
                            Text(occupationCity)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }
                }
                .padding(.horizontal, 28)
                Spacer(minLength: 0)

                // Vibe chip rows (two horizontal scrollers)
                if !vibeChips.isEmpty {
                    let rows = splitChips(vibeChips)
                    VStack(spacing: 6) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(row, id: \.self) { chip in
                                        Text(chip)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.white.opacity(0.25))
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.horizontal, 28)
                            }
                        }
                    }
                    .padding(.bottom, 14)
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
                VStack(alignment: .leading, spacing: 0) {
                    Text("LOOKING FOR")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.bottom, 8)

                    lookingForRow(label: "Budget", value: budgetText)
                    if !typeText.isEmpty {
                        Rectangle().fill(.white.opacity(0.10)).frame(height: 1).padding(.vertical, 6)
                        lookingForRow(label: "Type", value: typeText)
                    }
                    if !areasText.isEmpty {
                        Rectangle().fill(.white.opacity(0.10)).frame(height: 1).padding(.vertical, 6)
                        lookingForRow(label: "Areas", value: areasText)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.black.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 28)
                .padding(.bottom, 28)
            }
        }
        .frame(width: Self.cardWidth, height: Self.cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.primaryPurple.opacity(0.35), radius: 30, x: 0, y: 20)
    }

    private var avatarView: some View {
        Group {
            if let imageData = data.photoData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [.white, Color(hex: "E0E0E0")],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .overlay(Text("🦄").font(.system(size: 40)))
            }
        }
        .frame(width: 96, height: 96)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(Color.white.opacity(0.4), lineWidth: 4))
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)
    }

    private func lookingForRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            Spacer(minLength: 0)
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
    }

    private func splitChips(_ chips: [String]) -> [[String]] {
        guard !chips.isEmpty else { return [] }
        let mid = (chips.count + 1) / 2
        return [Array(chips.prefix(mid)), Array(chips.dropFirst(mid))]
    }
}
