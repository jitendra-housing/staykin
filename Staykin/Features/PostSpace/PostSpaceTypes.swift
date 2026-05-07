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

struct Amenity: Identifiable, Hashable {
    let id: Int
    let value: String
    let label: String
    let emoji: String

    var displayLabel: String {
        "\(emoji) \(label)"
    }
}

extension Amenity {
    static let parking        = Amenity(id: 1, value: "PARKING",          label: "Parking",     emoji: "🅿️")
    static let ac             = Amenity(id: 2, value: "AIR_CONDITIONING", label: "AC",          emoji: "❄️")
    static let kitchen        = Amenity(id: 3, value: "KITCHEN",          label: "Kitchen",     emoji: "🍳")
    static let washingMachine = Amenity(id: 4, value: "WASHING_MACHINE",  label: "Washing m/c", emoji: "🧺")
    static let lift           = Amenity(id: 5, value: "LIFT",             label: "Lift",        emoji: "🛗")
    static let balcony        = Amenity(id: 6, value: "BALCONY",          label: "Balcony",     emoji: "🌳")
    static let pool           = Amenity(id: 7, value: "POOL",             label: "Pool",        emoji: "🏊")

    static let all: [Amenity] = [.parking, .ac, .kitchen, .washingMachine, .lift, .balcony, .pool]

    static func find(by id: Int) -> Amenity? {
        all.first { $0.id == id }
    }
}

