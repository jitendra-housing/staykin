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
            if let thread = MockFlatmates.chatThread(by: threadId) {
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

    private func acceptFlatmate(flatmateId: Int) {
        if let thread = MockFlatmates.chatThreads.first(where: { $0.otherFlatmateId == flatmateId }) {
            // Replace the request-profile route with the chat so back goes straight to inbox.
            path = [.directChat(threadId: thread.id)]
        } else {
            path.removeLast()
        }
    }
}
