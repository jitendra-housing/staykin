import SwiftUI

struct FlatDetailView: View {
    let detail: FlatDetail
    let onBack: () -> Void

    @State private var selectedFlatmate: Flatmate? = nil
    @State private var showEnquirySent = false
    @State private var fetchedOwner: Flatmate? = nil

    private var renderedFlatmates: [Flatmate] {
        if !detail.flatmates.isEmpty { return detail.flatmates }
        return fetchedOwner.map { [$0] } ?? []
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    FlatHeroGallery(photos: detail.photos)

                    VStack(alignment: .leading, spacing: 0) {
                        titlePriceRow
                        TrustStrip(detail: detail).padding(.top, 10)
                        amenitiesSection.padding(.top, 16)
                        flatmatesSection.padding(.top, 18)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 24)
                }
            }
            .ignoresSafeArea(edges: .top)

            FlatTopNav(onBack: onBack)
                .padding(.horizontal, 16)
        }
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
        .staykinSheet(item: $selectedFlatmate, detents: [.height(490)]) { flatmate in
            FlatmateProfileSheet(flatmate: flatmate) {
                selectedFlatmate = nil
            }
        }
        .overlay(alignment: .bottom) {
            if showEnquirySent {
                SuccessToast(title: "Enquiry request sent")
                .padding(.horizontal, 16)
                .padding(.bottom, 96)   // sit above the sticky Enquire CTA
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.25), value: showEnquirySent)
        .task { await loadOwnerIfNeeded() }
        .task(id: showEnquirySent) {
            guard showEnquirySent else { return }
            try? await Task.sleep(for: .seconds(3))
            if !Task.isCancelled {
                showEnquirySent = false
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Rectangle().fill(Color.cardBorder).frame(height: 1)
                PrimaryButton(title: "Enquire", action: enquire)
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .background(Color.bgBase)
            }
        }
    }

    // MARK: - Enquire

    private var requestTargetUserId: Int? {
        renderedFlatmates.first(where: { $0.role == .poster })?.id
            ?? renderedFlatmates.first?.id
    }

    private func enquire() {
        showEnquirySent = true

        guard let targetId = requestTargetUserId else { return }
        Task {
            do {
                try await RequestsAPI.sendRequest(targetKind: .user, targetId: targetId)
            } catch {
                print("enquire failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Title + price

    private var titlePriceRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(detail.locality)
                    .font(.heading2)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                Text(detail.addressLine)
                    .font(.caption1)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 0) {
                Text(detail.rentLabel)
                    .font(.custom("Outfit", size: 22).weight(.bold))
                    .gradientForeground(.brand)
                Text("per month")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    // MARK: - Amenities

    private var amenitiesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "Amenities")
            FlowLayout(spacing: 6) {
                ForEach(detail.amenities) { amenity in
                    HStack(spacing: 5) {
                        Text(amenity.emoji).font(.system(size: 12))
                        Text(amenity.label).font(.system(size: 11, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.bgCard)
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(Color.cardBorder, lineWidth: 1))
                }
            }
        }
    }

    // MARK: - Flatmates

    private var flatmatesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                SectionLabel(text: "Who you'll live with")
                Spacer()
                Text("\(detail.slots.open) spot\(detail.slots.open == 1 ? "" : "s") left")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.textSecondary)
            }

            VStack(spacing: 8) {
                ForEach(renderedFlatmates) { mate in
                    FlatmateListRow(flatmate: mate, hideMatch: detail.isOwnListing, onTap: {
                        selectedFlatmate = mate
                    })
                }

                if let priv = detail.privateRoom, detail.slots.open > 0 {
                    EmptySlotRow(rentShare: priv.rentShare, availableNow: priv.availableNow)
                }
            }
        }
    }

    // MARK: - Owner fetch

    private func loadOwnerIfNeeded() async {
        guard !detail.isOwnListing,
              detail.flatmates.isEmpty,
              fetchedOwner == nil,
              let ownerId = detail.ownerUserId
        else { return }
        do {
            let (profile, _) = try await OnboardingAPI.getProfile(userId: ownerId)
            fetchedOwner = makeFlatmate(from: profile)
        } catch {
            print("getProfile(ownerUserId: \(ownerId)) failed: \(error)")
        }
    }

    private func makeFlatmate(from profile: UserProfile) -> Flatmate {
        let trimmedName = (profile.name ?? "").trimmingCharacters(in: .whitespaces)
        let name = trimmedName.isEmpty ? "Owner" : trimmedName
        let job = profile.occupation.flatMap { Occupation.find(by: $0)?.name } ?? "—"
        return Flatmate(
            id: profile.id,
            name: name,
            age: profile.age ?? 0,
            role: .poster,
            job: job,
            emoji: "🦊",
            avatarURL: profile.photoUrl,
            avatarHue: 280,
            avatarHue2: 320,
            matchPct: 0,
            vibePrefIds: profile.lifestyleTagIds ?? [],
            bio: "",
            lookingFor: []
        )
    }
}
