import SwiftUI

// Standalone NavigationStack for the Post-your-Space flow. Mirrors the
// `.fillRoomsInMyFlat` branch in OnboardingCoordinator but can be presented
// as a fullScreenCover from anywhere (e.g. FlatsTabView header).
struct PostSpaceCoordinator: View {
    let onDismiss: () -> Void
    let onViewMyListings: () -> Void

    @State private var data: OnboardingData
    @State private var path: [PostSpaceRoute] = []
    @State private var alertMessage: String?

    init(onDismiss: @escaping () -> Void, onViewMyListings: @escaping () -> Void) {
        self.onDismiss = onDismiss
        self.onViewMyListings = onViewMyListings
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
        .alert(
            "Couldn't publish",
            isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            ),
            actions: { Button("OK", role: .cancel) {} },
            message: { Text(alertMessage ?? "") }
        )
    }

    @ViewBuilder
    private func screen(for route: PostSpaceRoute) -> some View {
        switch route {
        case .photos:
            PhotosScreen(onContinue: {
                do {
                    _ = try await ListingsAPI.createListing(data)
                    path.append(.vibe)
                } catch {
                    alertMessage = "Couldn't create your listing — \(error.localizedDescription)"
                }
            }, onBack: pop)
        case .vibe:
            VibeScreen(onPublish: {
                do {
                    try await OnboardingAPI.patchProfile(data)
                    path.append(.success)
                } catch {
                    alertMessage = "Couldn't save your vibe — \(error.localizedDescription)"
                }
            }, onBack: pop)
        case .success:
            SuccessScreen(onViewListing: onViewMyListings, onBrowseFlatmates: onDismiss)
        }
    }

    private func pop() {
        if !path.isEmpty { path.removeLast() }
    }
}
