import SwiftUI

struct VibeFormScreen: View {
    let onContinue: () -> Void
    let onBack: () -> Void

    @Environment(OnboardingData.self) private var data

    private struct Pref {
        let emoji: String
        let label: String
    }

    private let prefs: [Pref] = [
        .init(emoji: "🦉", label: "Night Owl"),
        .init(emoji: "🌅", label: "Early Bird"),
        .init(emoji: "📚", label: "Book Worm"),
        .init(emoji: "🏋️", label: "Fitness Freak"),
        .init(emoji: "⚽", label: "Sporty"),
        .init(emoji: "✈️", label: "Wanderer"),
        .init(emoji: "🥳", label: "Party Lover"),
        .init(emoji: "🐶", label: "Pet Lover"),
        .init(emoji: "🥬", label: "Vegetarian"),
        .init(emoji: "🍗", label: "Non-Veg"),
        .init(emoji: "🥚", label: "Eggetarian"),
        .init(emoji: "🌱", label: "Vegan"),
        .init(emoji: "🍷", label: "Drinks Socially"),
        .init(emoji: "🚫", label: "Non Alcoholic"),
        .init(emoji: "🚬", label: "Smoker"),
        .init(emoji: "🚭", label: "Non Smoker"),
        .init(emoji: "🎸", label: "Music Lover"),
        .init(emoji: "🎮", label: "Gamer"),
        .init(emoji: "🍳", label: "Loves Cooking"),
        .init(emoji: "🎬", label: "Movie Buff"),
        .init(emoji: "🧘", label: "Yoga & Wellness"),
        .init(emoji: "💼", label: "WFH"),
        .init(emoji: "🧹", label: "Clean Freak"),
        .init(emoji: "😌", label: "Chill Vibes")
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private let minSelections = 5
    private var selectionCount: Int { data.vibePrefs.count }
    private var canContinue: Bool { selectionCount >= minSelections }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                StepPill(text: "Step 2 of 2", isAmber: true)
                    .padding(.top, Spacing.xs)

                Text("Choose your preferences")
                    .font(.custom("Outfit", size: 26).weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .padding(.top, 14)

                Text("Choose at least 5 preferences for better matches ✨")
                    .font(.bodySm)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.top, 6)

                HStack {
                    SectionLabel(text: "Pick your vibe")
                    Spacer()
                    Text("\(selectionCount)/\(minSelections) minimum")
                        .font(.caption1.weight(.bold))
                        .foregroundStyle(canContinue ? Color.success : Color.accentAmber)
                }
                .padding(.top, 22)
                .padding(.bottom, 14)

                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(prefs, id: \.label) { pref in
                        VibePrefCell(
                            emoji: pref.emoji,
                            label: pref.label,
                            isSelected: data.vibePrefs.contains(pref.label),
                            action: { toggle(pref.label) }
                        )
                    }
                }
            }
            .padding(.horizontal, Spacing.screenHPad)
            .padding(.bottom, 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.bgBase.opacity(0), Color.bgBase],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 24)

                PrimaryButton(
                    title: canContinue ? "Add Preferences →" : "Pick \(minSelections - selectionCount) more",
                    action: onContinue,
                    isDisabled: !canContinue
                )
                .padding(.horizontal, Spacing.screenHPad)
                .padding(.bottom, Spacing.xl)
                .background(Color.bgBase)
            }
        }
    }

    private func toggle(_ label: String) {
        if data.vibePrefs.contains(label) {
            data.vibePrefs.remove(label)
        } else {
            data.vibePrefs.insert(label)
        }
    }
}

private struct VibePrefCell: View {
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
