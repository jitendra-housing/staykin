import Foundation

struct RoomType: Identifiable, Hashable {
    let id: Int
    let value: String
    let label: String
    let emoji: String?    // iOS-only display

    var displayLabel: String {
        emoji.map { "\($0) \(label)" } ?? label
    }
}

extension RoomType {
    static let singleRoom = RoomType(id: 1, value: "SINGLE_ROOM", label: "Single Room", emoji: "🛏")
    static let sharing    = RoomType(id: 2, value: "SHARING",     label: "Sharing",     emoji: "👯")
    static let either     = RoomType(id: 3, value: "EITHER",      label: "Either",      emoji: "🤷")

    static let all: [RoomType] = [.singleRoom, .sharing, .either]

    static func find(by id: Int) -> RoomType? {
        all.first { $0.id == id }
    }
}
