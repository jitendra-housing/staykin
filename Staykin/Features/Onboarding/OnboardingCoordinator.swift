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
            ProfileScreen(onContinue: {
                Task { @MainActor in
                    do {
                        if let photoData = data.photoData, data.photoUrl == nil {
                            data.photoUrl = try await UploadsAPI.uploadImage(photoData, folder: "profile")
                        }
                        let profile = try await OnboardingAPI.submitProfile(data)
                        data.userId = profile.id
                    } catch {
                        print("submitProfile failed: \(error)")
                    }
                }
                push(.intent)
            })
        case .intent:
            IntentScreen(
                onContinue: { intent in
                    switch intent {
                    case .fillRoomsInMyFlat: push(.postFlatDetails)
                    case .moveIntoFlat, .teamUpToRent: push(.flatPrefs)
                    }
                },
                onBack: pop
            )
        case .flatPrefs:
            FlatPrefsScreen(onContinue: { push(.vibeForm) }, onBack: pop)
        case .vibeForm:
            VibeFormScreen(onContinue: {
                Task {
                    do { try await OnboardingAPI.patchProfile(data) }
                    catch { print("patchProfile failed: \(error)") }
                }
                push(.vibeCard)
            }, onBack: pop)
        case .vibeCard:
            VibeCardScreen(onFinish: onFinish, onBack: pop)
        case .postFlatDetails:
            FlatDetailsScreen(onContinue: { push(.postPhotos) }, onBack: pop)
        case .postPhotos:
            PhotosScreen(onContinue: { push(.postVibe) }, onBack: pop)
        case .postVibe:
            VibeScreen(onPublish: { push(.postSuccess) }, onBack: pop)
        case .postSuccess:
            SuccessScreen(onViewListing: onFinish, onBrowseFlatmates: onFinish)
        }
    }

    private func push(_ route: OnboardingRoute) {
        path.append(route)
    }

    private func pop() {
        if !path.isEmpty { path.removeLast() }
    }
}
