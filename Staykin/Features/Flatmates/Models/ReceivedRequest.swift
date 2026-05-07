import Foundation

// Server-shape returned by GET /requests/received/{user_id}.
//
// The response is *just* request metadata — it does not include the sender's
// profile. Displaying the sender's name / photo requires either a separate
// `GET /profile/{id}` call per request, or server-side enrichment.
struct ReceivedRequest: Decodable, Identifiable {
    let id: Int
    let fromUserId: Int
    let targetKind: Int          // 1 = user, 2 = team
    let targetUserId: Int?       // present when target is a user
    let targetTeamId: Int?       // present when target is a team
    let status: Int              // 1 = pending, 2 = accepted, 3 = declined
    let decidedAt: String?
    let createdAt: String
    let updatedAt: String?
}

extension ReceivedRequest {
    enum StatusCode: Int {
        case pending  = 1
        case accepted = 2
        case declined = 3
    }

    var statusCode: StatusCode? { StatusCode(rawValue: status) }
}
