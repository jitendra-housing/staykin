import SwiftUI

struct FlatmatesCoordinator: View {
    @State private var path: [FlatmatesRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            RequestsInboxScreen(
                onOpenProfile:     { flatmateId in path.append(.requestProfile(flatmateId: flatmateId, showActions: true)) },
                onOpenSentProfile: { flatmateId in path.append(.requestProfile(flatmateId: flatmateId, showActions: false)) },
                onOpenChat:        { threadId in path.append(.directChat(threadId: threadId)) },
                onAcceptRequest:   { userId in
                    // Chat backend isn't integrated yet — open a mock thread so the
                    // chat screen has populated header + messages. Prefer a mock
                    // thread matching the accepted user, else fall back to any.
                    let mockThreadId = MockFlatmates.chatThreads.first(where: { $0.otherFlatmateId == userId })?.id
                        ?? MockFlatmates.chatThreads.first?.id
                    if let mockThreadId {
                        path.append(.directChat(threadId: mockThreadId))
                    }
                },
                onDeclineRequest:  { _ in /* row dismissed in screen; nothing else to do */ }
            )
            .navigationDestination(for: FlatmatesRoute.self) { route in
                screen(for: route)
            }
        }
        .tint(.primaryPurple)
    }

    @ViewBuilder
    private func screen(for route: FlatmatesRoute) -> some View {
        switch route {
        case let .requestProfile(flatmateId, showActions):
            RequestProfileLoader(
                flatmateId: flatmateId,
                showActions: showActions,
                onAccept:  { acceptFlatmate(flatmateId: flatmateId) },
                onDecline: { path.removeLast() },
                onBack:    { path.removeLast() }
            )
        case .directChat(let threadId):
            // For live rooms RequestsInboxScreen passes the *other user's* id;
            // we synthesize a ChatThread on top of the registered Flatmate so
            // the messaging UI keeps working unchanged. For mock rows we still
            // resolve against MockFlatmates.chatThread.
            if let thread = liveThread(forUserId: threadId)
                ?? MockFlatmates.chatThread(by: threadId) {
                FlatmateChatScreen(
                    thread: thread,
                    onBack:        { path.removeLast() },
                    onOpenProfile: { path.append(.requestProfile(flatmateId: thread.otherFlatmateId, showActions: false)) },
                    onOpenGroup:   { path.append(.groupChat(threadId: MockFlatmates.groupThread.id)) }
                )
            } else {
                ChatsTabPlaceholder()
            }
        case .groupChat:
            GroupChatScreen(
                thread: MockFlatmates.groupThread,
                onBack:        { path.removeLast() },
                onOpenProfile: { flatmateId in path.append(.requestProfile(flatmateId: flatmateId, showActions: false)) }
            )
        }
    }

    // Builds a ChatThread for live data — id == userId so back navigation works,
    // otherFlatmateId resolves to the registered live flatmate.
    private func liveThread(forUserId userId: Int) -> ChatThread? {
        guard MockFlatmates.find(by: userId) != nil else { return nil }
        return ChatThread(
            id: userId,
            otherFlatmateId: userId,
            lastMessage: "",
            timeAgo: "",
            unreadCount: 0
        )
    }

    private func acceptFlatmate(flatmateId: Int) {
        if let thread = MockFlatmates.chatThreads.first(where: { $0.otherFlatmateId == flatmateId }) {
            // Replace the request-profile route with the chat so back goes straight to inbox.
            path = [.directChat(threadId: thread.id)]
        } else {
            path.removeLast()
        }
    }
}

// Fetches a profile by id and renders RequestProfileScreen once loaded.
// Shows a spinner while in-flight and a back-only error state on failure.
private struct RequestProfileLoader: View {
    let flatmateId: Int
    var showActions: Bool = true
    let onAccept: () -> Void
    let onDecline: () -> Void
    let onBack: () -> Void

    @State private var flatmate: Flatmate?
    @State private var failed = false

    var body: some View {
        Group {
            if let flatmate {
                RequestProfileScreen(
                    flatmate: flatmate,
                    showActions: showActions,
                    onAccept: onAccept,
                    onDecline: onDecline,
                    onBack: onBack
                )
            } else if failed {
                errorState
            } else {
                loadingState
            }
        }
        .task { await load() }
    }

    private var loadingState: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            ProgressView().tint(Color.primaryPurple)
        }
        .navigationBarBackButtonHidden(true)
    }

    private var errorState: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()
            VStack(spacing: 12) {
                Text("Couldn't load profile")
                    .font(.bodyLg.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Button("Back", action: onBack)
                    .foregroundStyle(Color.primaryPurple)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func load() async {
        let viewerId = UserStore.saved?.id
            ?? (UserDefaults.standard.object(forKey: OnboardingAPI.userIdDefaultsKey) as? Int)
        do {
            let (profile, _) = try await OnboardingAPI.getProfile(userId: flatmateId, viewerId: viewerId)
            flatmate = Flatmate(profile: profile)
        } catch {
            print("getProfile(\(flatmateId)) failed: \(error)")
            failed = true
        }
    }
}
