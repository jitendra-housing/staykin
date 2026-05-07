import Foundation

enum RequestStatus: String, Hashable {
    case pending  = "PENDING"
    case accepted = "ACCEPTED"
    case declined = "DECLINED"

    var displayLabel: String {
        switch self {
        case .pending:  "⏳ Pending"
        case .accepted: "✓ Accepted"
        case .declined: "✕ Declined"
        }
    }
}

enum RequestDirection: String, Hashable {
    case received = "RECEIVED"
    case sent     = "SENT"
}

struct FlatmateRequest: Identifiable, Hashable {
    let id: Int
    let otherFlatmateId: Int
    let direction: RequestDirection
    let status: RequestStatus
    let message: String          // "wants to be your flatmate" / "sent · awaiting reply"
    let timeAgo: String          // "2m" / "1h" / "1d" — pre-formatted for v1

    var otherFlatmate: Flatmate? {
        MockFlatmates.find(by: otherFlatmateId)
    }
}
