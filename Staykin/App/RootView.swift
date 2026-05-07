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
            HomeView()
        }
    }
}

enum AppPhase {
    case splash
    case onboarding
    case home
}
