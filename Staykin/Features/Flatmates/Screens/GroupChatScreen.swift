import SwiftUI

struct GroupChatScreen: View {
    let thread: GroupChatThread
    let onBack: () -> Void
    let onOpenProfile: (Int) -> Void   // flatmateId of the tapped sender avatar

    @State private var draft: String = ""
    @State private var localMessages: [ChatMessage] = []

    private var allMessages: [ChatMessage] {
        MockFlatmates.groupMessages + localMessages
    }

    private var avatarSpecs: [OverlappingAvatars.Spec] {
        // Lead "you" + each member.
        [.init(hue: 280, hue2: 320, emoji: "🦄")]
            + thread.members.map(OverlappingAvatars.Spec.init(flatmate:))
    }

    private var memberCount: Int { thread.members.count + 1 }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(allMessages) { message in
                        bubble(for: message)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ChatComposer(
                text: $draft,
                placeholder: "Message the squad 💬",
                onSend: sendMessage
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            OverlappingAvatars(specs: avatarSpecs, size: 32, overlap: 10)

            VStack(alignment: .leading, spacing: 0) {
                Text(thread.name)
                    .font(.bodySm.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                Text("\(memberCount) members")
                    .font(.caption1)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Image(systemName: "info.circle")
                .font(.system(size: 18))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, 12)
        .frame(height: 72)
        .background(Color.bgSheet)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.cardBorder).frame(height: 1)
        }
    }

    // MARK: - Bubbles

    @ViewBuilder
    private func bubble(for message: ChatMessage) -> some View {
        if message.direction == .incoming,
           let senderId = message.senderFlatmateId,
           let sender = MockFlatmates.find(by: senderId) {
            ChatBubble(
                message: message,
                sender: sender,
                onAvatarTap: { onOpenProfile(senderId) }
            )
        } else {
            ChatBubble(message: message)
        }
    }

    // MARK: - Send

    private func sendMessage() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let nextId = (allMessages.map(\.id).max() ?? 0) + 1
        localMessages.append(
            ChatMessage(
                id: nextId,
                threadId: thread.id,
                senderFlatmateId: nil,
                direction: .outgoing,
                text: trimmed,
                timestamp: Date()
            )
        )
        draft = ""
    }
}
