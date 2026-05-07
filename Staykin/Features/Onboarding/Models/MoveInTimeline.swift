import Foundation

struct MoveInTimeline: Identifiable, Hashable {
    let id: Int
    let value: String
    let label: String
    let emoji: String?    // iOS-only display

    var displayLabel: String {
        emoji.map { "\(label) \($0)" } ?? label    // emoji at end ("ASAP 🚀")
    }
}

extension MoveInTimeline {
    static let asap        = MoveInTimeline(id: 1, value: "ASAP",                label: "ASAP",            emoji: "🚀")
    static let withinMonth = MoveInTimeline(id: 2, value: "WITHIN_ONE_MONTH",    label: "Within 1 month",  emoji: nil)
    static let oneToThree  = MoveInTimeline(id: 3, value: "ONE_TO_THREE_MONTHS", label: "1–3 months",      emoji: nil)

    static let all: [MoveInTimeline] = [.asap, .withinMonth, .oneToThree]

    static func find(by id: Int) -> MoveInTimeline? {
        all.first { $0.id == id }
    }
}
