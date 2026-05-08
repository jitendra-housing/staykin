import SwiftUI

struct FlatmatesTabView: View {
    @State private var entries: [FlatmateEntry] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var hasVibe: Bool = !(UserStore.saved?.lifestyleTagIds?.isEmpty ?? true)
    @State private var showVibeEditor: Bool = false

    // Map API entries → swipe candidates, preserving team identity so the
    // POST /requests call can target the right kind (team vs single user).
    private var candidates: [SwipeCandidate] {
        entries.compactMap { entry -> SwipeCandidate? in
            switch entry {
            case .team(let team, let members):
                guard !members.isEmpty else { return nil }
                return .team(team, members: members)
            case .user(let user):
                return .user(user)
            }
        }
    }

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()

            VStack(spacing: 0) {
                if !hasVibe { vibeToast }

                if isLoading {
                    Spacer()
                    ProgressView().tint(Color.primaryPurple)
                    Spacer()
                } else if let errorMessage {
                    Spacer()
                    errorState(errorMessage)
                    Spacer()
                } else {
                    FlatmatesSwipeView(candidates: candidates)
                }
            }
        }
        .task { await load() }
        .sheet(isPresented: $showVibeEditor) {
            EditVibeSheet(
                initial: Set(UserStore.saved?.lifestyleTagIds ?? []),
                onSaved: { Task { await load() } }
            )
        }
    }

    private var vibeToast: some View {
        Button { showVibeEditor = true } label: {
            HStack(spacing: 12) {
                Text("✨").font(.system(size: 22))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Set your vibe to find matches")
                        .font(.bodySm.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                    Text("Without it, everyone shows 0% match")
                        .font(.caption1)
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(14)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.primaryPurple.opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text("Couldn't load flatmates")
                .font(.heading2)
                .foregroundStyle(Color.textPrimary)
            Text(message)
                .font(.caption1)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .lineLimit(4)
            Button {
                Task { await load() }
            } label: {
                Text("Retry")
                    .font(.bodySm.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(LinearGradient.brand)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    @MainActor
    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            entries = try await FlatmatesAPI.fetchFlatmates()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
        await refreshVibeStatus()
    }

    @MainActor
    private func refreshVibeStatus() async {
        let userId = UserStore.saved?.id
            ?? (UserDefaults.standard.object(forKey: OnboardingAPI.userIdDefaultsKey) as? Int)
        guard let userId else { return }
        do {
            let profile = try await OnboardingAPI.fetchProfile(userId: userId)
            withAnimation(.easeInOut(duration: 0.2)) {
                hasVibe = !(profile.lifestyleTagIds?.isEmpty ?? true)
            }
        } catch {
            print("refreshVibeStatus failed: \(error)")
        }
    }
}
