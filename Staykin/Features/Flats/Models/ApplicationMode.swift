import Foundation

struct ApplicationMode: Identifiable, Hashable {
    let id: Int
    let value: String
    let label: String
    let emoji: String

    var displayLabel: String { "\(emoji) \(label)" }
}

extension ApplicationMode {
    static let solo  = ApplicationMode(id: 1, value: "SOLO",  label: "Solo",  emoji: "👤")
    static let squad = ApplicationMode(id: 2, value: "SQUAD", label: "Squad", emoji: "👯")

    static let all: [ApplicationMode] = [.solo, .squad]

    static func find(by id: Int) -> ApplicationMode? {
        all.first { $0.id == id }
    }
}
