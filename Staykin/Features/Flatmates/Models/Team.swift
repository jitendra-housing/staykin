import Foundation

// Server-shaped team / squad object returned by GET /flatmates/{user_id}.
struct Team: Codable, Equatable, Identifiable, Hashable {
    let id: Int
    let ownerUserId: Int
    let name: String
}
