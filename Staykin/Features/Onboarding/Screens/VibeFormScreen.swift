import SwiftUI

struct VibeFormScreen: View {
    let onContinue: () -> Void
    let onBack: () -> Void

    @Environment(OnboardingData.self) private var data

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var selectionCount: Int { data.vibePrefs.count }
    private var canContinue: Bool { selectionCount >= VibePref.minSelections }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(Color.bgCard)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(Color.cardBorder, lineWidth: 1))
                }
                .padding(.top, Spacing.sm)

                StepPill(text: "Step 2 of 2", isAmber: true)
                    .padding(.top, Spacing.md)

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
                    Text("\(selectionCount)/\(VibePref.minSelections) minimum")
                        .font(.caption1.weight(.bold))
                        .foregroundStyle(canContinue ? Color.success : Color.accentAmber)
                }
                .padding(.top, 22)
                .padding(.bottom, 14)

                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(VibePref.all) { pref in
                        VibePrefCell(
                            emoji: pref.emoji,
                            label: pref.label,
                            isSelected: data.vibePrefs.contains(pref.id),
                            action: { toggle(pref.id) }
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
                    title: canContinue ? "Add Preferences →" : "Pick \(VibePref.minSelections - selectionCount) more",
                    action: onContinue,
                    isDisabled: !canContinue
                )
                .padding(.horizontal, Spacing.screenHPad)
                .padding(.bottom, Spacing.xl)
                .background(Color.bgBase)
            }
        }
    }

    private func toggle(_ id: Int) {
        if data.vibePrefs.contains(id) {
            data.vibePrefs.remove(id)
        } else {
            data.vibePrefs.insert(id)
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
