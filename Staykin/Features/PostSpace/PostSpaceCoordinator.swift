import SwiftUI

// Standalone NavigationStack for the Post-your-Space flow. Mirrors the
// `.fillRoomsInMyFlat` branch in OnboardingCoordinator but can be presented
// as a fullScreenCover from anywhere (e.g. FlatsTabView header).
struct PostSpaceCoordinator: View {
    let onDismiss: () -> Void

    @State private var data: OnboardingData
    @State private var path: [PostSpaceRoute] = []

    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        // The post-flow screens use @Environment(OnboardingData.self) for the
        // listing fields. Seed a fresh OnboardingData with the registered user's
        // id so ListingsAPI.createListing has owner_user_id wired up.
        let data = OnboardingData()
        if let profile = UserStore.saved {
            data.userId = profile.id
        }
        _data = State(initialValue: data)
    }

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
        .environment(data)
        .tint(.primaryPurple)
    }

    @ViewBuilder
    private func screen(for route: PostSpaceRoute) -> some View {
        switch route {
        case .photos:
            PhotosScreen(onContinue: {
                Task {
                    do { try await ListingsAPI.createListing(data) }
                    catch { print("createListing failed: \(error)") }
                }
                path.append(.vibe)
            }, onBack: pop)
        case .vibe:
            VibeScreen(onPublish: {
                Task {
                    do { try await OnboardingAPI.patchProfile(data) }
                    catch { print("patchProfile failed: \(error)") }
                }
                path.append(.success)
            }, onBack: pop)
        case .success:
            SuccessScreen(onViewListing: onDismiss, onBrowseFlatmates: onDismiss)
        }
    }

    private func pop() {
        if !path.isEmpty { path.removeLast() }
    }
}
