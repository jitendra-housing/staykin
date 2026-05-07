import SwiftUI

struct FlatmatesTabView: View {
    @State private var entries: [FlatmateEntry] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

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

            if isLoading {
                ProgressView().tint(Color.primaryPurple)
            } else if let errorMessage {
                errorState(errorMessage)
            } else {
                FlatmatesSwipeView(candidates: candidates)
            }
        }
        .task { await load() }
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
    }
}
