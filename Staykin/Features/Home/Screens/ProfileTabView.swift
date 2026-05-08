import SwiftUI

enum ProfileRoute: Hashable {
    case myListings
}

struct ProfileTabView: View {
    let onSignOut: () -> Void
    @Binding var path: NavigationPath

    @State private var notificationsEnabled: Bool = true
    @State private var showSignOutConfirm: Bool = false
    @State private var loadedProfile: UserProfile? = UserStore.saved

    private var profile: UserProfile? { loadedProfile }

    private var hasSquad: Bool { !(profile?.teamMemberIds?.isEmpty ?? true) }

    // TODO: replace mocks with real squad endpoint when available.
    private var squadMembers: [Flatmate] {
        guard hasSquad else { return [] }
        return [1, 2].compactMap(MockFlatmates.find(by:))
    }
    private var hasListing: Bool { !(profile?.listingIds?.isEmpty ?? true) }

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .myListings:
                        MyListingsScreen(
                            listingIds: profile?.listingIds ?? [],
                            onBack: { pop() }
                        )
                    }
                }
                .navigationDestination(for: FlatDetail.self) { detail in
                    FlatDetailView(detail: detail, onBack: { pop() })
                }
        }
        .tint(.primaryPurple)
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                vibeCard
                if !squadMembers.isEmpty { squadCard }
                listingCard
                settingsCard
                signOutButton
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
        .alert("Sign out?", isPresented: $showSignOutConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Sign out", role: .destructive, action: onSignOut)
        } message: {
            Text("You'll go through onboarding again next time you open the app.")
        }
        .task { await refreshProfile() }
    }

    private func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    private func refreshProfile() async {
        let myId = UserStore.saved?.id
            ?? (UserDefaults.standard.object(forKey: OnboardingAPI.userIdDefaultsKey) as? Int)
        guard let userId = myId else { return }
        do {
            let fetched = try await OnboardingAPI.fetchProfile(userId: userId)
            let raw = fetched.lifestyleTagIds ?? []
            let resolved = raw.map { id -> String in
                VibePref.find(by: id).map { "\($0.id):\($0.label)" } ?? "\(id):<no-match>"
            }
            print("[ProfileTabView] lifestyleTagIds raw=\(raw) resolved=\(resolved)")
            loadedProfile = fetched
        } catch {
            print("fetchProfile failed: \(error)")
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        HStack(spacing: 14) {
            avatar
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(LinearGradient.brand, lineWidth: 2))

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.heading2)
                    .foregroundStyle(Color.textPrimary)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption1)
                        .foregroundStyle(Color.textSecondary)
                }
                if let phone = profile?.phone, !phone.isEmpty {
                    Text(phone)
                        .font(.caption1)
                        .foregroundStyle(Color.textDisabled)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .strokeBorder(Color.cardBorder, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var avatar: some View {
        if let urlString = profile?.photoUrl,
           !urlString.isEmpty,
           let url = URL(string: urlString) {
            AsyncImage(url: url) { imagePhase in
                if let image = imagePhase.image {
                    image.resizable().scaledToFill()
                } else {
                    avatarFallback
                }
            }
        } else {
            avatarFallback
        }
    }

    private var avatarFallback: some View {
        ZStack {
            LinearGradient.brand
            Text("🦄").font(.system(size: 32))
        }
    }

    private var displayName: String {
        guard let name = profile?.name, !name.isEmpty else { return "You" }
        if let age = profile?.age { return "\(name), \(age)" }
        return name
    }

    private var subtitle: String {
        let occupationName = profile?.occupation.flatMap { Occupation.find(by: $0)?.name } ?? ""
        return occupationName
    }

    // MARK: - Vibe

    private var vibeCard: some View {
        let tags = (profile?.lifestyleTagIds ?? [])
            .compactMap(VibePref.find(by:))
            .map { "\($0.emoji) \($0.label)" }

        return VStack(alignment: .leading, spacing: 12) {
            sectionHeader("✨", "My vibe")

            if tags.isEmpty {
                Text("No vibe set yet")
                    .font(.bodySm)
                    .foregroundStyle(Color.textSecondary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption1.weight(.medium))
                            .foregroundStyle(Color(hex: "C4B5FD"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.primaryPurple.opacity(0.1))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().strokeBorder(Color.primaryPurple.opacity(0.25), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .strokeBorder(Color.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Squad

    private var squadCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("👯", "My squad")
                Spacer()
                Text("\(squadMembers.count + 1) members")
                    .font(.caption1)
                    .foregroundStyle(Color.textSecondary)
            }

            OverlappingAvatars(
                specs: [.init(hue: 280, hue2: 320, emoji: "🦄")]
                    + squadMembers.map(OverlappingAvatars.Spec.init(flatmate:)),
                size: 36, overlap: 12
            )
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color.cardBorder)
                .frame(height: 1)

            VStack(spacing: 10) {
                ForEach(squadMembers) { member in
                    memberRow(member)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .strokeBorder(Color.cardBorder, lineWidth: 1)
        )
    }

    private func memberRow(_ member: Flatmate) -> some View {
        HStack(spacing: 12) {
            Avatar(flatmate: member, size: 36)

            VStack(alignment: .leading, spacing: 1) {
                Text(member.name)
                    .font(.bodySm.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(member.job)
                    .font(.caption1)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Text("\(member.matchPct)% match")
                .font(.caption1.weight(.bold))
                .foregroundStyle(Color.accentAmber)
        }
    }

    // MARK: - Listing

    @ViewBuilder
    private var listingCard: some View {
        if hasListing {
            Button { path.append(ProfileRoute.myListings) } label: {
                listingCardContent
            }
            .buttonStyle(.plain)
        } else {
            listingCardContent
        }
    }

    private var listingCardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("🏠", "My listing\(listingCount > 1 ? "s" : "")")
                Spacer()
                if hasListing {
                    HStack(spacing: 4) {
                        Text("\(listingCount)")
                            .font(.caption1.weight(.bold))
                            .foregroundStyle(Color.textSecondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }

            if hasListing {
                Text("Active · \(listingCount) live")
                    .font(.caption1.weight(.semibold))
                    .foregroundStyle(Color.success)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No listing yet")
                        .font(.bodySm.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text("Post your space to find flatmates who vibe with your home.")
                        .font(.caption1)
                        .foregroundStyle(Color.textSecondary)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .strokeBorder(Color.cardBorder, lineWidth: 1)
        )
    }

    private var listingCount: Int { profile?.listingIds?.count ?? 0 }

    // MARK: - Settings

    private var settingsCard: some View {
        VStack(spacing: 0) {
            sectionHeader("⚙️", "Settings")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)

            settingsRow(icon: "bell", title: "Notifications") {
                Toggle("", isOn: $notificationsEnabled)
                    .labelsHidden()
                    .tint(Color.primaryPurple)
            }
            divider
            settingsRow(icon: "lock", title: "Privacy") { chevron }
            divider
            settingsRow(icon: "questionmark.circle", title: "Help & support") { chevron }
        }
        .padding(16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .strokeBorder(Color.cardBorder, lineWidth: 1)
        )
    }

    private func settingsRow<Trailing: View>(
        icon: String,
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 22)
            Text(title)
                .font(.bodySm)
                .foregroundStyle(Color.textPrimary)
            Spacer()
            trailing()
        }
        .frame(height: 44)
    }

    private var divider: some View {
        Rectangle().fill(Color.cardBorder).frame(height: 1)
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.textSecondary)
    }

    // MARK: - Sign out

    private var signOutButton: some View {
        Button { showSignOutConfirm = true } label: {
            Text("Sign out")
                .font(.buttonLg)
                .foregroundStyle(Color.destructive)
                .frame(maxWidth: .infinity)
                .frame(height: ComponentSize.buttonHeight)
                .background(Color.destructive.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: Radius.full))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.full)
                        .strokeBorder(Color.destructive.opacity(0.4), lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func sectionHeader(_ emoji: String, _ title: String) -> some View {
        HStack(spacing: 8) {
            Text(emoji)
            Text(title)
                .font(.bodyLg.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
        }
    }
}
