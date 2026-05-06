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
            VibeCardScreen(onFinish: onFinish, onBack: pop)
        }
    }

    private func push(_ route: OnboardingRoute) {
        path.append(route)
    }

    private func pop() {
        if !path.isEmpty { path.removeLast() }
    }
}
