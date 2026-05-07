import SwiftUI

struct FlatmatesCoordinator: View {
    @State private var path: [FlatmatesRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            RequestsInboxScreen(
                onOpenProfile:    { flatmateId in path.append(.requestProfile(flatmateId: flatmateId)) },
                onOpenChat:       { threadId in path.append(.directChat(threadId: threadId)) },
                onAcceptRequest:  { _ in /* TODO wire to API */ },
                onDeclineRequest: { _ in /* TODO wire to API */ }
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
        case .requestProfile(let flatmateId):
            if let flatmate = MockFlatmates.find(by: flatmateId) {
                RequestProfileScreen(
                    flatmate: flatmate,
                    onAccept:  { acceptFlatmate(flatmateId: flatmateId) },
                    onDecline: { path.removeLast() },
                    onBack:    { path.removeLast() }
                )
            } else {
                ChatsTabPlaceholder()
            }
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
                    onOpenProfile: { path.append(.requestProfile(flatmateId: thread.otherFlatmateId)) },
                    onOpenGroup:   { path.append(.groupChat(threadId: MockFlatmates.groupThread.id)) }
                )
            } else {
                ChatsTabPlaceholder()
            }
        case .groupChat:
            GroupChatScreen(
                thread: MockFlatmates.groupThread,
                onBack:        { path.removeLast() },
                onOpenProfile: { flatmateId in path.append(.requestProfile(flatmateId: flatmateId)) }
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
