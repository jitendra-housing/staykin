import SwiftUI

struct RequestsInboxScreen: View {
    let onOpenProfile: (Int) -> Void           // userId — avatar taps + received/sent row body taps
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

    // Received tab API state
    @State private var receivedRequests: [ReceivedRequest] = []
    @State private var receivedLoading: Bool = false
    @State private var receivedError: String?

    // Chat tab API state
    @State private var rooms: [Room] = []
    @State private var roomsLoading: Bool = false
    @State private var roomsError: String?

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
                    case .chat:    chatList
                    case .received: receivedList
                    case .sent:    sentList
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
        .task {
            async let received: () = loadReceived()
            async let chats: ()    = loadRooms()
            _ = await (received, chats)
        }
    }

    // MARK: - Chat (API)

    @ViewBuilder
    private var chatList: some View {
        if roomsLoading {
            ProgressView().tint(Color.primaryPurple)
                .padding(.top, 24)
        } else if let roomsError {
            chatErrorView(roomsError)
        } else if rooms.isEmpty {
            Text("No chats yet")
                .font(.bodySm)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
        } else {
            ForEach(rooms) { room in
                RoomRow(
                    room: room,
                    onRowTap: { onOpenChat(room.id) }
                )
            }
        }
    }

    private func chatErrorView(_ message: String) -> some View {
        VStack(spacing: 10) {
            Text("Couldn't load chats")
                .font(.bodySm.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
            Text(message)
                .font(.caption1)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(4)
            Button {
                Task { await loadRooms() }
            } label: {
                Text("Retry")
                    .font(.caption1.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(LinearGradient.brand)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }

    @MainActor
    private func loadRooms() async {
        roomsLoading = true
        roomsError = nil
        do {
            rooms = try await RoomsAPI.fetchRooms()
        } catch {
            roomsError = error.localizedDescription
        }
        roomsLoading = false
    }

    // MARK: - Received (API)

    @ViewBuilder
    private var receivedList: some View {
        if receivedLoading {
            ProgressView().tint(Color.primaryPurple)
                .padding(.top, 24)
        } else if let receivedError {
            receivedErrorView(receivedError)
        } else if visibleReceived.isEmpty {
            Text("No new requests")
                .font(.bodySm)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
        } else {
            ForEach(visibleReceived) { request in
                ReceivedRequestRow(
                    request: request,
                    onAvatarTap: { onOpenProfile(request.fromUserId) },
                    onRowTap:    { onOpenProfile(request.fromUserId) },
                    onAccept:  { Task { await acceptRequest(request.id) } },
                    onDecline: { Task { await rejectRequest(request.id) } }
                )
            }
        }
    }

    private var visibleReceived: [ReceivedRequest] {
        receivedRequests
            .filter { ($0.statusCode ?? .pending) == .pending }   // only show pending
            .filter { !actionedRequestIds.contains($0.id) }
    }

    private func receivedErrorView(_ message: String) -> some View {
        VStack(spacing: 10) {
            Text("Couldn't load requests")
                .font(.bodySm.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
            Text(message)
                .font(.caption1)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(4)
            Button {
                Task { await loadReceived() }
            } label: {
                Text("Retry")
                    .font(.caption1.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(LinearGradient.brand)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }

    @MainActor
    private func loadReceived() async {
        receivedLoading = true
        receivedError = nil
        do {
            receivedRequests = try await RequestsAPI.fetchReceived()
        } catch {
            receivedError = error.localizedDescription
        }
        receivedLoading = false
    }

    @MainActor
    private func acceptRequest(_ requestId: Int) async {
        withAnimation(.easeInOut(duration: 0.2)) {
            actionedRequestIds.insert(requestId)
        }
        do {
            _ = try await RequestsAPI.accept(requestId: requestId)
            onAcceptRequest(requestId)
        } catch {
            withAnimation(.easeInOut(duration: 0.2)) {
                actionedRequestIds.remove(requestId)
            }
            receivedError = error.localizedDescription
        }
    }

    @MainActor
    private func rejectRequest(_ requestId: Int) async {
        withAnimation(.easeInOut(duration: 0.2)) {
            actionedRequestIds.insert(requestId)
        }
        do {
            _ = try await RequestsAPI.reject(requestId: requestId)
            onDeclineRequest(requestId)
        } catch {
            withAnimation(.easeInOut(duration: 0.2)) {
                actionedRequestIds.remove(requestId)
            }
            receivedError = error.localizedDescription
        }
    }

    // MARK: - Sent (mock for now)

    private var sentList: some View {
        ForEach(MockFlatmates.sent) { request in
            SentRequestRow(
                request: request,
                onAvatarTap: { onOpenProfile(request.otherFlatmateId) },
                onRowTap:    { onOpenProfile(request.otherFlatmateId) }
            )
        }
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

private struct RoomRow: View {
    let room: Room
    let onRowTap: () -> Void

    // The /rooms response carries no participant info, so we render placeholders
    // until enrichment lands (server-side or per-row profile fetch).
    private var displayName: String { "Chat #\(room.id)" }
    private var avatarHue: Double { Double((room.id * 47) % 360) }

    var body: some View {
        Button(action: onRowTap) {
            RowCard {
                HStack(spacing: 12) {
                    Avatar(size: 48, hue: avatarHue, initial: nil)

                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(displayName)
                                    .font(.bodySm.weight(.bold))
                                    .foregroundStyle(Color.textPrimary)
                                Spacer()
                                Text(timeAgo(room.createdAt))
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.textDisabled)
                            }
                            Text("Tap to open conversation")
                                .font(.caption1)
                                .foregroundStyle(Color.textSecondary)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct ReceivedRequestRow: View {
    let request: ReceivedRequest
    let onAvatarTap: () -> Void
    let onRowTap: () -> Void
    let onAccept: () -> Void
    let onDecline: () -> Void

    // The /requests/received response only carries `from_user_id`, so we render a
    // placeholder identity until a `GET /profile/{id}` lookup is wired in.
    private var displayName: String { "User #\(request.fromUserId)" }
    private var avatarHue: Double { Double((request.fromUserId * 47) % 360) }

    var body: some View {
        RowCard {
            HStack(spacing: 12) {
                Button(action: onAvatarTap) {
                    Avatar(size: 48, hue: avatarHue, initial: nil)
                }
                .buttonStyle(.plain)

                Button(action: onRowTap) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(displayName)
                                .font(.bodySm.weight(.semibold))
                                .foregroundStyle(Color.textPrimary)
                            Text("wants to be your flatmate")
                                .font(.bodySm)
                                .foregroundStyle(Color.textSecondary)
                                .lineLimit(1)
                        }
                        Text(timeAgo(request.createdAt))
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

// MARK: - Helpers

private let isoDateFormatter: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return f
}()

private let isoDateFormatterNoFraction: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime]
    return f
}()

private let relativeFormatter: RelativeDateTimeFormatter = {
    let f = RelativeDateTimeFormatter()
    f.unitsStyle = .abbreviated
    return f
}()

private func timeAgo(_ iso: String) -> String {
    let date = isoDateFormatter.date(from: iso)
        ?? isoDateFormatterNoFraction.date(from: iso)
    guard let date else { return "" }
    return relativeFormatter.localizedString(for: date, relativeTo: Date())
}
