import SwiftUI

// Standalone NavigationStack for the Post-your-Space flow. Mirrors the
// `.fillRoomsInMyFlat` branch in OnboardingCoordinator but can be presented
// as a fullScreenCover from anywhere (e.g. FlatsTabView header).
struct PostSpaceCoordinator: View {
    let onDismiss: () -> Void

    @State private var path: [PostSpaceRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            FlatDetailsScreen(
                onContinue: { path.append(.photos) },
                onBack: onDismiss
            )
            .navigationDestination(for: PostSpaceRoute.self) { route in
                screen(for: route)
            }
        }
        .tint(.primaryPurple)
    }

    @ViewBuilder
    private func screen(for route: PostSpaceRoute) -> some View {
        switch route {
        case .photos:
            PhotosScreen(onContinue: { path.append(.vibe) }, onBack: pop)
        case .vibe:
            VibeScreen(onPublish: { path.append(.success) }, onBack: pop)
        case .success:
            SuccessScreen(onViewListing: onDismiss, onBrowseFlatmates: onDismiss)
        }
    }

    private func pop() {
        if !path.isEmpty { path.removeLast() }
    }
}
