import SwiftUI

struct FlatmatesTabView: View {
    @State private var entries: [FlatmateEntry] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    // Flatten API entries → list of swipe candidates.
    // Team entries contribute their members; user entries contribute themselves.
    private var candidates: [Flatmate] {
        entries.flatMap { entry -> [Flatmate] in
            switch entry {
            case .team(_, let members): return members.map { Flatmate(profile: $0) }
            case .user(let user):       return [Flatmate(profile: user)]
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
