import SwiftUI

struct OnboardingCoordinator: View {
    let onFinish: () -> Void

    @State private var data = OnboardingData()
    @State private var path: [OnboardingRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            screen(for: .phone)
                .navigationDestination(for: OnboardingRoute.self) { route in
                    screen(for: route)
                }
        }
        .environment(data)
        .tint(.primaryPurple)
    }

    @ViewBuilder
    private func screen(for route: OnboardingRoute) -> some View {
        switch route {
        case .phone:
            PhoneScreen(onContinue: { push(.otp) })
        case .otp:
            OTPScreen(onVerify: { push(.profile) }, onBack: pop)
        case .profile:
            ProfileScreen(onContinue: { push(.intent) })
        case .intent:
            IntentScreen(onContinue: { push(.flatPrefs) }, onBack: pop)
        case .flatPrefs:
            FlatPrefsScreen(onContinue: { push(.vibeForm) }, onBack: pop)
        case .vibeForm:
            VibeFormScreen(onContinue: { push(.vibeCard) }, onBack: pop)
        case .vibeCard:
            PlaceholderScreen(title: "Your vibe card is ready! 🪩", route: route, showBack: true, onBack: pop, ctaTitle: "Start searching ✨", onContinue: onFinish)
        }
    }

    private func push(_ route: OnboardingRoute) {
        path.append(route)
    }

    private func pop() {
        if !path.isEmpty { path.removeLast() }
    }
}

// MARK: - Placeholder (replaced screen-by-screen in upcoming steps)

private struct PlaceholderScreen: View {
    let title: String
    let route: OnboardingRoute
    var stepLabel: String? = nil
    var stepIsAmber: Bool = false
    var showBack: Bool
    let onBack: () -> Void
    var ctaTitle: String = "Continue"
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if showBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.bgCard)
                            .clipShape(Circle())
                            .overlay(Circle().strokeBorder(Color.cardBorder, lineWidth: 1))
                    }
                }
                Spacer()
            }
            .padding(.top, Spacing.sm)
            .padding(.horizontal, Spacing.screenHPad)

            if let stepLabel {
                Text(stepLabel)
                    .font(.caption1)
                    .foregroundStyle(stepIsAmber ? Color.accentAmber : Color(hex: "C4B5FD"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(stepIsAmber
                            ? Color.accentAmber.opacity(0.14)
                            : Color.primaryPurple.opacity(0.08))
                    )
                    .overlay(
                        Capsule().strokeBorder(stepIsAmber
                            ? Color.accentAmber.opacity(0.25)
                            : Color.primaryPurple.opacity(0.18))
                    )
                    .padding(.horizontal, Spacing.screenHPad)
                    .padding(.top, Spacing.sm)
            }

            Spacer()
            VStack(alignment: .center, spacing: Spacing.xs) {
                Text(title)
                    .font(.display)
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.screenHPad)
            Spacer()

            PrimaryButton(title: ctaTitle, action: onContinue)
                .padding(.horizontal, Spacing.screenHPad)
                .padding(.bottom, Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
    }
}
