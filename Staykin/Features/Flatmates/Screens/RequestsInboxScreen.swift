import SwiftUI

struct RequestsInboxScreen: View {
    let onOpenProfile: (Int) -> Void           // flatmateId — avatar taps + received/sent row body taps
    let onOpenChat: (Int) -> Void              // threadId — chat row body tap
    let onAcceptRequest: (Int) -> Void         // requestId — received ✓
    let onDeclineRequest: (Int) -> Void        // requestId — received ✕

    enum InboxTab: Hashable {
        case chat
        case received
        case sent
    }

    @State private var tab: InboxTab = .chat
    @State private var actionedRequestIds: Set<Int> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Requests")
                .font(.heading1)
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)

            SegmentedTabBar(
                selection: $tab,
                segments: [
                    (.chat,     "Chat"),
                    (.received, "Received"),
                    (.sent,     "Sent")
                ]
            )
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.md)

            ScrollView {
                LazyVStack(spacing: 8) {
                    switch tab {
                    case .chat:
                        ForEach(MockFlatmates.chatThreads) { thread in
                            ChatThreadRow(
                                thread: thread,
                                onAvatarTap: { onOpenProfile(thread.otherFlatmateId) },
                                onRowTap:    { onOpenChat(thread.id) }
                            )
                        }
                    case .received:
                        let visible = MockFlatmates.received.filter { !actionedRequestIds.contains($0.id) }
                        ForEach(visible) { request in
                            ReceivedRequestRow(
                                request: request,
                                onAvatarTap: { onOpenProfile(request.otherFlatmateId) },
                                onRowTap:    { onOpenProfile(request.otherFlatmateId) },
                                onAccept: {
                                    onAcceptRequest(request.id)
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        actionedRequestIds.insert(request.id)
                                    }
                                },
                                onDecline: {
                                    onDeclineRequest(request.id)
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        actionedRequestIds.insert(request.id)
                                    }
                                }
                            )
                        }
                    case .sent:
                        ForEach(MockFlatmates.sent) { request in
                            SentRequestRow(
                                request: request,
                                onAvatarTap: { onOpenProfile(request.otherFlatmateId) },
                                onRowTap:    { onOpenProfile(request.otherFlatmateId) }
                            )
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
    }
}

// MARK: - Rows

private struct RowCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(14)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.cardBorder, lineWidth: 1)
            )
    }
}

private struct ChatThreadRow: View {
    let thread: ChatThread
    let onAvatarTap: () -> Void
    let onRowTap: () -> Void

    var body: some View {
        if let other = thread.otherFlatmate {
            RowCard {
                HStack(spacing: 12) {
                    Button(action: onAvatarTap) {
                        Avatar(flatmate: other, size: 48)
                    }
                    .buttonStyle(.plain)

                    Button(action: onRowTap) {
                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(other.name)
                                        .font(.bodySm.weight(.bold))
                                        .foregroundStyle(Color.textPrimary)
                                    Spacer()
                                    Text(thread.timeAgo)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(Color.textDisabled)
                                }
                                Text(thread.lastMessage)
                                    .font(.caption1)
                                    .foregroundStyle(Color.textSecondary)
                                    .lineLimit(1)
                            }

                            if thread.unreadCount > 0 {
                                Text("\(thread.unreadCount)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(minWidth: 22, minHeight: 22)
                                    .padding(.horizontal, 7)
                                    .background(LinearGradient.brand)
                                    .clipShape(Capsule())
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct ReceivedRequestRow: View {
    let request: FlatmateRequest
    let onAvatarTap: () -> Void
    let onRowTap: () -> Void
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        if let other = request.otherFlatmate {
            RowCard {
                HStack(spacing: 12) {
                    Button(action: onAvatarTap) {
                        Avatar(flatmate: other, size: 48)
                    }
                    .buttonStyle(.plain)

                    Button(action: onRowTap) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text(other.name)
                                    .font(.bodySm.weight(.semibold))
                                    .foregroundStyle(Color.textPrimary)
                                Text(request.message)
                                    .font(.bodySm)
                                    .foregroundStyle(Color.textSecondary)
                                    .lineLimit(1)
                            }
                            Text("\(request.timeAgo) ago")
                                .font(.caption1)
                                .foregroundStyle(Color.textDisabled)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    HStack(spacing: 6) {
                        Button(action: onDecline) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.destructive)
                                .frame(width: 32, height: 32)
                                .background(Color.destructive.opacity(0.1))
                                .clipShape(Circle())
                                .overlay(Circle().strokeBorder(Color.destructive.opacity(0.4), lineWidth: 1.5))
                        }
                        .buttonStyle(.plain)

                        Button(action: onAccept) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.success)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct SentRequestRow: View {
    let request: FlatmateRequest
    let onAvatarTap: () -> Void
    let onRowTap: () -> Void

    var body: some View {
        if let other = request.otherFlatmate {
            RowCard {
                HStack(spacing: 12) {
                    Button(action: onAvatarTap) {
                        Avatar(flatmate: other, size: 48)
                    }
                    .buttonStyle(.plain)

                    Button(action: onRowTap) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text(other.name)
                                    .font(.bodySm.weight(.semibold))
                                    .foregroundStyle(Color.textPrimary)
                                Text("· \(request.message)")
                                    .font(.bodySm)
                                    .foregroundStyle(Color.textSecondary)
                                    .lineLimit(1)
                            }
                            Text("\(request.timeAgo) ago")
                                .font(.caption1)
                                .foregroundStyle(Color.textDisabled)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    statusPill(for: request.status)
                }
            }
        }
    }

    private func statusPill(for status: RequestStatus) -> some View {
        let color: Color = {
            switch status {
            case .accepted: Color.success
            case .declined: Color.destructive
            case .pending:  Color.accentAmber
            }
        }()

        return Text(status.displayLabel)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.14))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(color.opacity(0.4), lineWidth: 1))
    }
}
