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
                do {
                    let id = try await ListingsAPI.createListing(data)
                    data.listingIds.append(id)
                } catch {
                    print("createListing failed: \(error)")
                }
                push(.postVibe)
            }, onBack: pop)
        case .postVibe:
            VibeScreen(onPublish: {
                // Mirror listing fields into the user-preference fields so the
                // PATCH /profile body includes preferred_locality_ids and bhk_prefs
                // alongside lifestyle_tag_ids.
                if let locality = data.listingLocalityId { data.areas.insert(locality) }
                if let bhk = data.listingBHK { data.bhk.insert(bhk) }
                Task {
                    do { try await OnboardingAPI.patchProfile(data) }
                    catch { print("patchProfile failed: \(error)") }
                }
                push(.postSuccess)
            }, onBack: pop)
        case .postSuccess:
            SuccessScreen(
                onViewListing: {
                    let detail = await fetchOwnListingAsDetail()
                    handleFinish(.flatDetail(detail))
                },
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

    private func fetchOwnListingAsDetail() async -> FlatDetail {
        guard let id = data.listingIds.last else { return MockFlats.detail }
        do {
            let listing = try await ListingsAPI.getListing(id: id)
            return makeDetail(from: listing)
        } catch {
            print("getListing failed: \(error)")
            return MockFlats.detail
        }
    }

    private func makeDetail(from listing: Listing) -> FlatDetail {
        let photos: [FlatPhoto] = (listing.photos ?? []).enumerated().map { idx, url in
            FlatPhoto(
                id: idx,
                url: url,
                placeholderHue: 280,
                placeholderHue2: 320,
                placeholderEmoji: "🏠"
            )
        }
        let total = listing.flatmatesNeeded + 1     // poster (you) + needed slots
        let slots = FlatSlots(total: total, filled: 1)
        let poster = makePosterFlatmate(listing: listing)
        return FlatDetail(
            id: listing.id,
            typeId: FlatType.privateRoom.id,
            locality: Area.find(by: listing.localityId)?.name ?? "—",
            addressLine: "",
            rent: listing.monthlyRent,
            bhkId: listing.bhk,
            furnishingId: listing.furnishing,
            areaSqft: 0,
            verified: false,
            availableNow: listing.moveIn == 1,
            score: 100,
            photos: photos,
            amenityIds: listing.amenities ?? [],
            flatmates: [poster],
            combinedMatch: CombinedMatch(
                score: 100,
                summary: "Your listing",
                participants: [poster.name]
            ),
            slots: slots,
            privateRoom: nil,
            about: "",
            isOwnListing: true,
            ownerUserId: listing.ownerUserId
        )
    }

    private func makePosterFlatmate(listing: Listing) -> Flatmate {
        let trimmedName = data.name.trimmingCharacters(in: .whitespaces)
        let name = trimmedName.isEmpty ? "You" : trimmedName
        let job = data.occupation.flatMap { Occupation.find(by: $0)?.name } ?? "—"
        let lookingFor: [LookingForItem] = [
            LookingForItem(label: "Move-in", value: MoveInTimeline.find(by: listing.moveIn)?.label ?? "—"),
            LookingForItem(label: "BHK",     value: BHK.find(by: listing.bhk)?.label ?? "—"),
            LookingForItem(label: "Vibe",    value: vibeSummary(from: data.vibePrefs))
        ]
        return Flatmate(
            id: data.userId ?? listing.ownerUserId,
            name: name,
            age: data.age ?? 0,
            role: .poster,
            job: job,
            emoji: "🦊",
            avatarURL: data.photoUrl,
            avatarHue: 280,
            avatarHue2: 320,
            matchPct: 100,
            vibePrefIds: Array(data.vibePrefs).sorted(),
            bio: "",
            lookingFor: lookingFor
        )
    }

    private func vibeSummary(from prefs: Set<Int>) -> String {
        let labels = prefs.sorted().compactMap(VibePref.find(by:)).map(\.label).prefix(3)
        return labels.isEmpty ? "—" : labels.joined(separator: " · ")
    }
}
