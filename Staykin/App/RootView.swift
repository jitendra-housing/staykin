import SwiftUI

struct RootView: View {
    @State private var phase: AppPhase

    init() {
        let initial: AppPhase
        if UserStore.onboardingComplete {
            initial = .home
        } else if UserStore.snapshot != nil {
            initial = .onboarding
        } else if UserStore.saved != nil {
            // Pre-snapshot user with a saved profile — treat as already onboarded.
            UserStore.onboardingComplete = true
            initial = .home
        } else {
            initial = .splash
        }
        _phase = State(initialValue: initial)
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
                UserStore.clearSnapshot()
                UserStore.onboardingComplete = false
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
