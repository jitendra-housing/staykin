import SwiftUI

struct OnboardingCoordinator: View {
    let onFinish: (HomeLanding) -> Void

    @State private var data: OnboardingData
    @State private var path: [OnboardingRoute]
    @Environment(\.scenePhase) private var scenePhase

    init(onFinish: @escaping (HomeLanding) -> Void) {
        self.onFinish = onFinish
        let restored = UserStore.snapshot
        let data = OnboardingData()
        restored?.apply(to: data)
        _data = State(initialValue: data)
        _path = State(initialValue: restored?.path ?? [])
    }

    var body: some View {
        NavigationStack(path: $path) {
            screen(for: .phone)
                .navigationDestination(for: OnboardingRoute.self) { route in
                    screen(for: route)
                }
        }
        .environment(data)
        .tint(.primaryPurple)
        .onChange(of: path) { _, _ in saveSnapshot() }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                saveSnapshot()
            }
        }
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
            VibeCardScreen(onFinish: { handleFinish(.flatsList) }, onBack: pop)
        case .postFlatDetails:
            FlatDetailsScreen(onContinue: { push(.postPhotos) }, onBack: pop)
        case .postPhotos:
            PhotosScreen(onContinue: {
                do { try await ListingsAPI.createListing(data) }
                catch { print("createListing failed: \(error)") }
                push(.postVibe)
            }, onBack: pop)
        case .postVibe:
            VibeScreen(onPublish: {
                Task {
                    do { try await OnboardingAPI.patchProfile(data) }
                    catch { print("patchProfile failed: \(error)") }
                }
                push(.postSuccess)
            }, onBack: pop)
        case .postSuccess:
            // Until POST /listings returns the created Flat, stub "view my listing"
            // with the first mock flat. Swap to the real returned listing once wired.
            SuccessScreen(
                onViewListing:    { handleFinish(.flatDetail(MockFlats.list[0])) },
                onBrowseFlatmates: { handleFinish(.flatmates) }
            )
        }
    }

    private func push(_ route: OnboardingRoute) {
        path.append(route)
    }

    private func pop() {
        if !path.isEmpty { path.removeLast() }
    }

    private func saveSnapshot() {
        UserStore.save(snapshot: OnboardingSnapshot(data: data, path: path))
    }

    private func handleFinish(_ landing: HomeLanding) {
        UserStore.clearSnapshot()
        UserStore.onboardingComplete = true
        onFinish(landing)
    }
}
