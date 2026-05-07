import SwiftUI

struct RequestsInboxScreen: View {
    let onOpenProfile: (Int) -> Void           // userId — received row taps (shows accept/decline)
    let onOpenSentProfile: (Int) -> Void       // userId — sent row taps (no accept/decline)
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
    @State private var roomOtherUser: [Int: Flatmate] = [:]   // roomId → other participant

    // Sent tab API state
    @State private var sentRequests: [RequestOut] = []
    @State private var sentLoaded: Bool = false
    @State private var sentLoading: Bool = false
    @State private var sentError: String?
    @State private var flatmateById: [Int: Flatmate] = [:]

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
        .task(id: tab) {
            if tab == .sent && !sentLoaded {
                await loadSent()
            }
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
                    flatmate: roomOtherUser[room.id],
                    onRowTap: {
                        // Pass the other-user id (or fall back to room id) so
                        // FlatmatesCoordinator can resolve the chat header.
                        let id = roomOtherUser[room.id]?.id ?? room.id
                        onOpenChat(id)
                    }
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
            // Fetch rooms + the data needed to enrich each row with the other
            // participant's name and avatar.
            async let roomsTask = RoomsAPI.fetchRooms()
            async let sentTask = RequestsAPI.fetchSent()
            async let receivedTask = RequestsAPI.fetchReceived()
            async let flatmatesTask = FlatmatesAPI.fetchFlatmates()

            let fetchedRooms = try await roomsTask
            let sent = (try? await sentTask) ?? []
            let received = (try? await receivedTask) ?? []
            let flatmateEntries = (try? await flatmatesTask) ?? []

            // 1) Register live flatmates so MockFlatmates.find(by:) resolves
            //    them downstream (FlatmateChatScreen, ChatThread, etc.).
            var liveFlatmates: [Flatmate] = []
            for entry in flatmateEntries {
                switch entry {
                case .user(let u):
                    liveFlatmates.append(Flatmate(profile: u))
                case .team(_, let members):
                    for m in members { liveFlatmates.append(Flatmate(profile: m)) }
                }
            }
            MockFlatmates.register(liveFlatmates)
            let flatmatesById = Dictionary(uniqueKeysWithValues: liveFlatmates.map { ($0.id, $0) })

            // 2) Build requestId → otherUserId by combining sent + received.
            let me = UserDefaults.standard.object(forKey: OnboardingAPI.userIdDefaultsKey) as? Int
            var otherByRequestId: [Int: Int] = [:]
            for r in sent {
                if let target = r.targetUserId {
                    otherByRequestId[r.id] = target
                }
            }
            for r in received {
                // For received, "other" is the sender — unless sender is me, then it's the target.
                if r.fromUserId != me {
                    otherByRequestId[r.id] = r.fromUserId
                } else if let target = r.targetUserId {
                    otherByRequestId[r.id] = target
                }
            }

            // 3) Build roomId → Flatmate.
            var byRoom: [Int: Flatmate] = [:]
            for room in fetchedRooms {
                if let userId = otherByRequestId[room.requestId],
                   let flatmate = flatmatesById[userId] {
                    byRoom[room.id] = flatmate
                }
            }

            rooms = fetchedRooms
            roomOtherUser = byRoom
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

    // MARK: - Sent (API)

    @ViewBuilder
    private var sentList: some View {
        if sentLoading && sentRequests.isEmpty {
            ProgressView().tint(Color.primaryPurple)
                .padding(.top, 24)
        } else if let sentError, sentRequests.isEmpty {
            sentErrorView(sentError)
        } else if sentRequests.isEmpty {
            Text("No requests sent yet")
                .font(.bodySm)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
        } else {
            ForEach(sentRequests) { request in
                LiveSentRequestRow(
                    request: request,
                    flatmate: flatmateById[request.targetUserId ?? -1],
                    onTap: {
                        if let userId = request.targetUserId {
                            onOpenSentProfile(userId)
                        }
                    }
                )
            }
        }
    }

    private func sentErrorView(_ message: String) -> some View {
        VStack(spacing: 10) {
            Text("Couldn't load")
                .font(.bodySm.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
            Text(message)
                .font(.caption1)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(4)
            Button {
                Task { await loadSent() }
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
    private func loadSent() async {
        sentLoading = true
        sentError = nil
        do {
            async let requestsTask = RequestsAPI.fetchSent()
            async let flatmatesTask = FlatmatesAPI.fetchFlatmates()

            let reqs = try await requestsTask
            let entries = (try? await flatmatesTask) ?? []

            var map: [Int: Flatmate] = [:]
            for entry in entries {
                switch entry {
                case .user(let u):
                    map[u.id] = Flatmate(profile: u)
                case .team(_, let members):
                    for m in members { map[m.id] = Flatmate(profile: m) }
                }
            }

            sentRequests = reqs.sorted { $0.createdAt > $1.createdAt }
            flatmateById = map
            sentLoaded = true
        } catch {
            sentError = error.localizedDescription
        }
        sentLoading = false
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
    let flatmate: Flatmate?
    let onRowTap: () -> Void

    private var displayName: String {
        flatmate?.name ?? "Chat #\(room.id)"
    }

    var body: some View {
        Button(action: onRowTap) {
            RowCard {
                HStack(spacing: 12) {
                    if let flatmate {
                        Avatar(flatmate: flatmate, size: 48)
                    } else {
                        Avatar(size: 48, hue: Double((room.id * 47) % 360), initial: nil)
                    }

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

    @State private var fetchedName: String?

    private var displayName: String {
        fetchedName ?? "User #\(request.fromUserId)"
    }
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
        .task { await loadName() }
    }

    private func loadName() async {
        guard fetchedName == nil else { return }
        do {
            let (profile, _) = try await OnboardingAPI.getProfile(userId: request.fromUserId)
            let trimmed = (profile.name ?? "").trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty { fetchedName = trimmed }
        } catch {
            print("getProfile(\(request.fromUserId)) failed: \(error)")
        }
    }
}

// Live sent-request row driven by GET /requests/sent.
private struct LiveSentRequestRow: View {
    let request: RequestOut
    let flatmate: Flatmate?
    let onTap: () -> Void

    private var status: RequestStatus {
        switch request.status {
        case 2:  return .accepted
        case 3:  return .declined
        default: return .pending
        }
    }

    private var titleText: String {
        if let name = flatmate?.name { return name }
        if request.targetKind == 2, let teamId = request.targetTeamId {
            return "Team #\(teamId)"
        }
        if let userId = request.targetUserId { return "User #\(userId)" }
        return "Request #\(request.id)"
    }

    private var statusMessage: String {
        switch status {
        case .pending:  return "sent · awaiting reply"
        case .accepted: return "accepted! tap to chat"
        case .declined: return "declined your request"
        }
    }

    var body: some View {
        Button(action: onTap) {
            RowCard {
                HStack(spacing: 12) {
                    if let flatmate {
                        Avatar(flatmate: flatmate, size: 48)
                    } else {
                        Avatar(size: 48, hue: 0, initial: nil)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(titleText)
                                .font(.bodySm.weight(.semibold))
                                .foregroundStyle(Color.textPrimary)
                            Text("· \(statusMessage)")
                                .font(.bodySm)
                                .foregroundStyle(Color.textSecondary)
                                .lineLimit(1)
                        }
                        Text(timeAgo(request.createdAt))
                            .font(.caption1)
                            .foregroundStyle(Color.textDisabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    statusPill
                }
                .contentShape(Rectangle())
            }
        }
        .buttonStyle(.plain)
    }

    private var statusPill: some View {
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
