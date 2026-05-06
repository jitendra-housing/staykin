import SwiftUI

struct RootView: View {
    @State private var phase: AppPhase = .splash

    var body: some View {
        switch phase {
        case .splash:
            SplashView(onFinish: { phase = .onboarding })
        case .onboarding:
            OnboardingCoordinator(onFinish: { phase = .home })
        case .home:
            // Home tab bar — implemented later
            Text("Home coming soon")
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.bgBase)
        }
    }
}

enum AppPhase {
    case splash
    case onboarding
    case home
}
