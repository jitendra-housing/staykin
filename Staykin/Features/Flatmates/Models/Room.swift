import Foundation

// Server shape returned by GET /rooms?user_id=…
//
// The endpoint returns only room metadata — no participant profile, last
// message, or unread count. Displaying real names / previews / counts will
// need either server-side enrichment or extra fetches per row.
struct Room: Decodable, Identifiable {
    let id: Int
    let requestId: Int
    let flatmateTeamId: Int?
    let addFlatmateEnabled: Bool
    let createdAt: String
}
