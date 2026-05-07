import Foundation

// Server response to POST /requests/{request_id}/accept and /reject.
// Same shape as ReceivedRequest plus a per-user decision log and the
// chat room id created once both sides have accepted.
struct RequestActionResponse: Decodable, Identifiable {
    let id: Int
    let fromUserId: Int
    let targetKind: Int
    let targetUserId: Int?
    let targetTeamId: Int?
    let status: Int
    let decidedAt: String?
    let createdAt: String
    let updatedAt: String?
    let decisions: [RequestDecision]
    let roomId: Int?
}

struct RequestDecision: Decodable, Hashable {
    let userId: Int
    let decision: Int        // assumed: 0 = pending, 1 = accepted, 2 = declined
    let decidedAt: String
}
