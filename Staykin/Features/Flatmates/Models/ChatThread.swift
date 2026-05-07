import Foundation

struct ChatThread: Identifiable, Hashable {
    let id: Int
    let otherFlatmateId: Int
    let lastMessage: String
    let timeAgo: String
    let unreadCount: Int

    var otherFlatmate: Flatmate? {
        MockFlatmates.find(by: otherFlatmateId)
    }
}

struct GroupChatThread: Identifiable, Hashable {
    let id: Int
    let name: String                  // "🏠 Koramangala Squad"
    let memberFlatmateIds: [Int]
    let slotsNeeded: Int              // total slots required to complete the squad
    let lastMessage: String
    let timeAgo: String

    var members: [Flatmate] {
        memberFlatmateIds.compactMap(MockFlatmates.find(by:))
    }

    var slotsRemaining: Int {
        max(0, slotsNeeded - memberFlatmateIds.count)
    }
}
