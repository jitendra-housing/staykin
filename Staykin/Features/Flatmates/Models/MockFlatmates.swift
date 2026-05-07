import Foundation

// Mock fixtures for the Chats / Flatmate System until the API is wired in.
enum MockFlatmates {

    // MARK: - Profiles

    static let all: [Flatmate] = [
        // 1 — Priya (received request, top chat thread, group member)
        .init(
            id: 1, name: "Priya", age: 24, role: .poster,
            job: "Marketing @ Swiggy",
            emoji: "🌸", avatarURL: nil, avatarHue: 320, avatarHue2: 280,
            matchPct: 87,
            vibePrefIds: [7, 13, 9, 6, 1, 2, 20, 15],
            bio: "chronic plant parent (i have 23, send help). work in marketing but i'm built like a designer. looking for someone who won't judge me for ordering biryani 3 times a week 🥲",
            lookingFor: [
                .init(label: "Budget", value: "₹15–20K /mo"),
                .init(label: "Type",   value: "2 BHK · 3 BHK"),
                .init(label: "Areas",  value: "Koramangala, Indiranagar")
            ]
        ),
        // 2 — Rahul (received request, group member)
        .init(
            id: 2, name: "Rahul", age: 26, role: .flatmate,
            job: "iOS dev",
            emoji: "🚀", avatarURL: nil, avatarHue: 220, avatarHue2: 280,
            matchPct: 82,
            vibePrefIds: [2, 22, 8, 11, 20],
            bio: "swift by day, switch by night. clean room, clean code 💻",
            lookingFor: [
                .init(label: "Budget", value: "₹14–18K /mo"),
                .init(label: "Type",   value: "2 BHK"),
                .init(label: "Move-in", value: "Within 1 month")
            ]
        ),
        // 3 — Karan (received request, chat thread)
        .init(
            id: 3, name: "Karan", age: 28, role: .flatmate,
            job: "Product @ Cred",
            emoji: "🦁", avatarURL: nil, avatarHue: 180, avatarHue2: 220,
            matchPct: 75,
            vibePrefIds: [8, 16, 18, 20, 21],
            bio: "early bird, gym at 6, in bed by 11. tea > coffee, fight me ☕",
            lookingFor: [
                .init(label: "Budget",  value: "₹16–22K /mo"),
                .init(label: "Move-in", value: "ASAP")
            ]
        ),
        // 4 — Ashi (sent request, pending)
        .init(
            id: 4, name: "Ashi", age: 23, role: .flatmate,
            job: "Designer @ Razorpay",
            emoji: "✨", avatarURL: nil, avatarHue: 280, avatarHue2: 320,
            matchPct: 90,
            vibePrefIds: [13, 7, 1, 23, 21],
            bio: "art school dropout turned product designer. plants, lo-fi, late nights ✏️",
            lookingFor: [
                .init(label: "Budget", value: "₹18–24K /mo"),
                .init(label: "Areas",  value: "Indiranagar")
            ]
        ),
        // 5 — Vikram (sent request, pending)
        .init(
            id: 5, name: "Vikram", age: 27, role: .flatmate,
            job: "Backend dev",
            emoji: "🐯", avatarURL: nil, avatarHue: 200, avatarHue2: 240,
            matchPct: 71,
            vibePrefIds: [2, 22, 11, 17],
            bio: "wfh most days, run on the weekend, vegan since 2022 🌱",
            lookingFor: [
                .init(label: "Budget", value: "₹15–18K /mo")
            ]
        ),
        // 6 — Sara (sent request, declined)
        .init(
            id: 6, name: "Sara", age: 25, role: .flatmate,
            job: "Architect",
            emoji: "🌷", avatarURL: nil, avatarHue: 350, avatarHue2: 30,
            matchPct: 64,
            vibePrefIds: [13, 14, 19],
            bio: "sketches buildings, drinks black coffee, hikes on long weekends ⛰",
            lookingFor: [
                .init(label: "Areas", value: "HSR, Koramangala")
            ]
        ),
        // 7 — Ishaan (sent request, accepted)
        .init(
            id: 7, name: "Ishaan", age: 25, role: .flatmate,
            job: "Frontend dev",
            emoji: "🦊", avatarURL: nil, avatarHue: 150, avatarHue2: 190,
            matchPct: 84,
            vibePrefIds: [2, 22, 23, 12, 21],
            bio: "react and chai. down for game nights, weekend trips, occasional party 🎮",
            lookingFor: [
                .init(label: "Budget", value: "₹15–20K /mo"),
                .init(label: "Type",   value: "2 BHK · 3 BHK")
            ]
        )
    ]

    static func find(by id: Int) -> Flatmate? {
        all.first { $0.id == id }
    }

    // MARK: - Requests

    static let received: [FlatmateRequest] = [
        .init(id: 1, otherFlatmateId: 1, direction: .received, status: .pending,
              message: "wants to be your flatmate", timeAgo: "2m"),
        .init(id: 2, otherFlatmateId: 2, direction: .received, status: .pending,
              message: "wants to be your flatmate", timeAgo: "1h"),
        .init(id: 3, otherFlatmateId: 3, direction: .received, status: .pending,
              message: "wants to be your flatmate", timeAgo: "1d")
    ]

    static let sent: [FlatmateRequest] = [
        .init(id: 4, otherFlatmateId: 4, direction: .sent, status: .pending,
              message: "sent · awaiting reply", timeAgo: "5m"),
        .init(id: 5, otherFlatmateId: 5, direction: .sent, status: .pending,
              message: "sent · awaiting reply", timeAgo: "2h"),
        .init(id: 6, otherFlatmateId: 6, direction: .sent, status: .declined,
              message: "declined your request", timeAgo: "1d"),
        .init(id: 7, otherFlatmateId: 7, direction: .sent, status: .accepted,
              message: "accepted! tap to chat", timeAgo: "2d")
    ]

    // MARK: - Direct chat threads

    static let chatThreads: [ChatThread] = [
        .init(id: 1, otherFlatmateId: 1, lastMessage: "Hey! Thanks for the request 👋",
              timeAgo: "2m", unreadCount: 2),
        .init(id: 2, otherFlatmateId: 7, lastMessage: "Sure, let me share my schedule",
              timeAgo: "1h", unreadCount: 0),
        .init(id: 3, otherFlatmateId: 2, lastMessage: "You: sounds good!",
              timeAgo: "3h", unreadCount: 0),
        .init(id: 4, otherFlatmateId: 3, lastMessage: "When can we hop on a call?",
              timeAgo: "1d", unreadCount: 1)
    ]

    static func chatThread(by id: Int) -> ChatThread? {
        chatThreads.first { $0.id == id }
    }

    // MARK: - Direct chat messages

    // Keyed by thread id. The 1:1 chat with Priya (thread 1) mirrors the design.
    static let messagesByThreadId: [Int: [ChatMessage]] = [
        1: [
            .init(id: 101, threadId: 1, senderFlatmateId: 1, direction: .incoming,
                  text: "yo we should def be flatmates 👀 ur tags r unmatched",
                  timestamp: Date(timeIntervalSinceNow: -360)),
            .init(id: 102, threadId: 1, senderFlatmateId: nil, direction: .outgoing,
                  text: "literallyyy. same vibe energy fr 💅",
                  timestamp: Date(timeIntervalSinceNow: -300)),
            .init(id: 103, threadId: 1, senderFlatmateId: 1, direction: .incoming,
                  text: "do it do it do it 🥺",
                  timestamp: Date(timeIntervalSinceNow: -120))
        ]
    ]

    static func messages(for threadId: Int) -> [ChatMessage] {
        messagesByThreadId[threadId] ?? []
    }

    // MARK: - Group chat

    static let groupThread = GroupChatThread(
        id: 100,
        name: "🏠 Koramangala Squad",
        memberFlatmateIds: [1, 2],   // You + Priya + Rahul; "you" isn't in the array
        slotsNeeded: 3,
        lastMessage: "btw saw a 4th candidate 👀",
        timeAgo: "5m"
    )

    static let groupMessages: [ChatMessage] = [
        .init(id: 201, threadId: 100, senderFlatmateId: nil, direction: .system,
              text: "🎉 You're now flatmates!",
              timestamp: Date(timeIntervalSinceNow: -1200)),
        .init(id: 202, threadId: 100, senderFlatmateId: 1, direction: .incoming,
              text: "okayyy team!! when r we doing the flat tour",
              timestamp: Date(timeIntervalSinceNow: -900)),
        .init(id: 203, threadId: 100, senderFlatmateId: 2, direction: .incoming,
              text: "this weekend? im free sat 🙌",
              timestamp: Date(timeIntervalSinceNow: -800)),
        .init(id: 204, threadId: 100, senderFlatmateId: nil, direction: .outgoing,
              text: "SAT WORKS. bringing the chai ☕",
              timestamp: Date(timeIntervalSinceNow: -700)),
        .init(id: 205, threadId: 100, senderFlatmateId: nil, direction: .alert,
              text: "⚠️ Still looking for 1 more flatmate",
              timestamp: Date(timeIntervalSinceNow: -400)),
        .init(id: 206, threadId: 100, senderFlatmateId: nil, direction: .outgoing,
              text: "btw saw a 4th candidate 👀",
              timestamp: Date(timeIntervalSinceNow: -120))
    ]
}
