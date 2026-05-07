import Foundation

struct GenderPref: Identifiable, Hashable {
    let id: Int
    let value: String
    let label: String
    let emoji: String?

    var displayLabel: String {
        emoji.map { "\($0) \(label)" } ?? label
    }
}

extension GenderPref {
    static let girls = GenderPref(id: 1, value: "GIRLS_ONLY", label: "Girls only", emoji: "👧")
    static let boys  = GenderPref(id: 2, value: "BOYS_ONLY",  label: "Boys only",  emoji: "👦")
    static let mixed = GenderPref(id: 3, value: "MIXED",      label: "Mixed",      emoji: "🧍")

    static let all: [GenderPref] = [.girls, .boys, .mixed]

    static func find(by id: Int) -> GenderPref? {
        all.first { $0.id == id }
    }
}
