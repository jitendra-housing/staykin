import SwiftUI

struct RootView: View {
    @State private var phase: AppPhase

    init() {
        _phase = State(initialValue: UserStore.saved != nil ? .home : .splash)
    }

    var body: some View {
        switch phase {
        case .splash:
            SplashView(onFinish: { phase = .onboarding })
        case .onboarding:
            OnboardingCoordinator(onFinish: { phase = .home })
        case .home:
            HomeView(onSignOut: {
                UserStore.clear()
                phase = .onboarding
            })
        }
    }
}

enum AppPhase {
    case splash
    case onboarding
    case home
}
