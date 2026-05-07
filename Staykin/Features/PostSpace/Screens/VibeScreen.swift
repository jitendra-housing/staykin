import SwiftUI

struct VibeScreen: View {
    let onPublish: () -> Void
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
                PostStepHeader(
                    stepIndex: 2,
                    totalSteps: 3,
                    title: "What's your vibe? ✨",
                    subtitle: "Pick at least 5 — helps the right people self-filter",
                    onBack: onBack
                )
                .padding(.top, Spacing.sm)

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
                        VibeTile(
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
            StickyBottomCTA(
                title: canContinue
                    ? "Publish listing 🚀"
                    : "Pick \(VibePref.minSelections - selectionCount) more",
                action: onPublish,
                isDisabled: !canContinue
            )
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
