import SwiftUI

struct IntentScreen: View {
    let onContinue: () -> Void
    let onBack: () -> Void

    @Environment(OnboardingData.self) private var data

    private struct IntentInfo {
        let intent: UserIntent
        let emoji: String
        let title: String
        let subtitle: String
    }

    private let items: [IntentInfo] = [
        .init(intent: .moveIntoFlat, emoji: "🛏️", title: "Move into a flat",
              subtitle: "Find an existing flat with rooms available"),
        .init(intent: .fillRoomsInMyFlat, emoji: "🪧", title: "Fill rooms in my flat",
              subtitle: "I have a place, find flatmates to fill it"),
        .init(intent: .teamUpToRent, emoji: "🤝", title: "Team up to rent a flat",
              subtitle: "Find your squad, then hunt together")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Back button
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

            Text("What are you here for?")
                .font(.display)
                .foregroundStyle(Color.textPrimary)
                .padding(.top, 24)

            Text("You can always change this later")
                .font(.bodySm)
                .foregroundStyle(Color.textSecondary)
                .padding(.top, Spacing.xs)

            VStack(spacing: 12) {
                ForEach(items, id: \.intent) { item in
                    IntentCard(
                        icon: item.emoji,
                        title: item.title,
                        subtitle: item.subtitle,
                        isSelected: data.intent == item.intent,
                        action: { select(item.intent) }
                    )
                }
            }
            .padding(.top, 32)

            Spacer()
        }
        .padding(.horizontal, Spacing.screenHPad)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
    }

    private func select(_ intent: UserIntent) {
        data.intent = intent
        Task {
            try? await Task.sleep(for: .milliseconds(280))
            onContinue()
        }
    }
}
