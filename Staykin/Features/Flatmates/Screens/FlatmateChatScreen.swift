import SwiftUI

struct FlatmateChatScreen: View {
    let thread: ChatThread
    let onBack: () -> Void
    let onOpenProfile: () -> Void
    let onOpenGroup: () -> Void

    @State private var draft: String = ""
    @State private var localMessages: [ChatMessage] = []
    @State private var showAddSheet: Bool = false

    private var other: Flatmate? { thread.otherFlatmate }

    private var allMessages: [ChatMessage] {
        MockFlatmates.messages(for: thread.id) + localMessages
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 0) {
                    if let other {
                        vibeMatchChip(for: other)
                            .padding(.horizontal, 16)
                            .padding(.top, 10)

                        AmberBanner(
                            text: "Still need 2 more flatmates",
                            trailingText: "Browse →"
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }

                    LazyVStack(spacing: 8) {
                        ForEach(allMessages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ChatComposer(
                text: $draft,
                placeholder: "Type something fun 🎉",
                onSend: sendMessage
            )
        }
        .staykinSheet(isPresented: $showAddSheet, detents: [.height(460)]) {
            if let other = thread.otherFlatmate {
                AddFlatmateSheet(
                    flatmate: other,
                    slotsFilled: 1,
                    slotsNeeded: 3,
                    onConfirm: {
                        showAddSheet = false
                        onOpenGroup()
                    },
                    onCancel:  { showAddSheet = false }
                )
            }
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

            if let other {
                Button(action: onOpenProfile) {
                    Avatar(flatmate: other, size: 36)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 0) {
                    Text(other.name)
                        .font(.bodySm.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                    Text("⚡ \(other.matchPct)% vibe")
                        .font(.caption1)
                        .foregroundStyle(Color.accentAmber)
                }

                Spacer()

                Button { showAddSheet = true } label: {
                    Text("Add as Flatmate +")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(hex: "C4B5FD"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.primaryPurple.opacity(0.10))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().strokeBorder(LinearGradient.brand, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 64)
        .background(Color.bgSheet)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.cardBorder).frame(height: 1)
        }
    }

    // MARK: - Vibe match summary chip

    private func vibeMatchChip(for other: Flatmate) -> some View {
        let topVibes = other.vibePrefs.prefix(2).map { "\($0.emoji) \($0.label)" }
        let parts = ["⚡ \(other.matchPct)% match"] + topVibes
        let summary = parts.joined(separator: " · ")

        return HStack(spacing: 6) {
            Text(summary)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.bgCard)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Color.cardBorder, lineWidth: 1))
        .frame(maxWidth: .infinity, alignment: .leading)
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
