import Foundation

// Server-shape returned by GET /requests/received/{user_id}.
//
// The response is *just* request metadata — it does not include the sender's
// profile. Displaying the sender's name / photo requires either a separate
// `GET /profile/{id}` call per request, or server-side enrichment.
struct ReceivedRequest: Decodable, Identifiable {
    let id: Int
    let fromUserId: Int
    let targetKind: Int          // assumed: 0 = user, 1 = team
    let targetUserId: Int?       // present when target is a user
    let targetTeamId: Int?       // present when target is a team
    let status: Int              // assumed: 0 = pending, 1 = accepted, 2 = declined
    let decidedAt: String?
    let createdAt: String
    let updatedAt: String?
}

extension ReceivedRequest {
    enum StatusCode: Int {
        case pending  = 0
        case accepted = 1
        case declined = 2
    }

    var statusCode: StatusCode? { StatusCode(rawValue: status) }
}
