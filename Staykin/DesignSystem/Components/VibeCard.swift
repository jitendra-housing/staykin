import SwiftUI

// MARK: - DTO

struct VibeCardLookingFor: Hashable {
    let label: String
    let value: String
}

struct VibeCardProfile: Hashable {
    let badgeText: String                     // "MY VIBE" / "HER VIBE" / "THEIR VIBE"
    let firstName: String
    let age: Int?
    let occupation: String
    let city: String
    let photoData: Data?
    let avatarEmoji: String                   // fallback when photoData == nil
    let vibePrefIds: [Int]
    let lookingFor: [VibeCardLookingFor]

    var nameAndAge: String {
        if let age { return "\(firstName), \(age)" }
        return firstName
    }

    var occupationCity: String {
        [occupation, city].filter { !$0.isEmpty }.joined(separator: " · ")
    }

    var displayChips: [String] {
        vibePrefIds
            .compactMap(VibePref.find(by:))
            .map { "\($0.emoji) \($0.label)" }
    }
}

// MARK: - View

struct VibeCard: View {
    let profile: VibeCardProfile

    private static let cardWidth: CGFloat = 320
    private static let cardHeight: CGFloat = 480

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "8B5CF6"), Color(hex: "A78BFA"), Color(hex: "C4B5FD")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

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
                HStack {
                    Text("Staykin")
                        .font(.custom("Outfit", size: 20).weight(.heavy))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(profile.badgeText)
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

                Spacer(minLength: 0)
                VStack(spacing: 12) {
                    avatarView
                    VStack(spacing: 2) {
                        Text(profile.nameAndAge)
                            .font(.custom("Outfit", size: 26).weight(.bold))
                            .foregroundStyle(.white)
                        if !profile.occupationCity.isEmpty {
                            Text(profile.occupationCity)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }
                }
                .padding(.horizontal, 28)
                Spacer(minLength: 0)

                let chips = profile.displayChips
                if !chips.isEmpty {
                    let rows = splitChips(chips)
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

                if !profile.lookingFor.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("LOOKING FOR")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(1)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.bottom, 8)

                        ForEach(Array(profile.lookingFor.enumerated()), id: \.offset) { i, row in
                            if i > 0 {
                                Rectangle().fill(.white.opacity(0.10)).frame(height: 1).padding(.vertical, 6)
                            }
                            lookingForRow(row)
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
            if let imageData = profile.photoData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [.white, Color(hex: "E0E0E0")],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .overlay(Text(profile.avatarEmoji).font(.system(size: 40)))
            }
        }
        .frame(width: 96, height: 96)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(Color.white.opacity(0.4), lineWidth: 4))
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)
    }

    private func lookingForRow(_ row: VibeCardLookingFor) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(row.label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            Spacer(minLength: 0)
            Text(row.value)
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

// MARK: - Adapters

extension VibeCardProfile {
    init(onboarding data: OnboardingData) {
        let firstName = data.name.split(separator: " ").first.map(String.init)
            ?? (data.name.isEmpty ? "You" : data.name)

        var rows: [VibeCardLookingFor] = [
            .init(label: "Budget", value: "₹\(Int(data.budgetMin / 1000))–\(Int(data.budgetMax / 1000))K /mo")
        ]
        let bhkLabels = BHK.all.filter { data.bhk.contains($0.id) }.map(\.label)
        if !bhkLabels.isEmpty {
            rows.append(.init(label: "Type", value: bhkLabels.joined(separator: " · ")))
        }
        let areaNames = data.areas.sorted().compactMap(Area.find(by:)).prefix(3).map(\.name)
        if !areaNames.isEmpty {
            rows.append(.init(label: "Areas", value: areaNames.joined(separator: ", ")))
        }

        self.init(
            badgeText: "MY VIBE",
            firstName: firstName,
            age: data.age,
            occupation: data.occupation,
            city: data.city,
            photoData: data.photoData,
            avatarEmoji: "🦄",
            vibePrefIds: Array(data.vibePrefs).sorted(),
            lookingFor: rows
        )
    }

    init(flatmate: Flatmate, badgeText: String) {
        self.init(
            badgeText: badgeText,
            firstName: flatmate.name,
            age: flatmate.age,
            occupation: flatmate.job,
            city: "",
            photoData: nil,
            avatarEmoji: flatmate.emoji ?? "🦄",
            vibePrefIds: flatmate.vibePrefIds,
            lookingFor: flatmate.lookingFor.map { .init(label: $0.label, value: $0.value) }
        )
    }
}
