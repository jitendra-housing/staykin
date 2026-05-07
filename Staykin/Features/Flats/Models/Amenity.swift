import Foundation

struct Amenity: Identifiable, Hashable {
    let id: Int
    let value: String
    let label: String
    let emoji: String

    var displayLabel: String { "\(emoji) \(label)" }
}

extension Amenity {
    static let wifi          = Amenity(id: 1,  value: "WIFI",           label: "WiFi",            emoji: "📶")
    static let ac            = Amenity(id: 2,  value: "AC",             label: "AC",              emoji: "❄️")
    static let geyser        = Amenity(id: 3,  value: "GEYSER",         label: "Geyser",          emoji: "🔥")
    static let washer        = Amenity(id: 4,  value: "WASHER",         label: "Washing machine", emoji: "🧺")
    static let cctv          = Amenity(id: 5,  value: "CCTV",           label: "CCTV",            emoji: "📹")
    static let parking       = Amenity(id: 6,  value: "PARKING",        label: "Parking",         emoji: "🅿️")
    static let lift          = Amenity(id: 7,  value: "LIFT",           label: "Lift",            emoji: "🛗")
    static let gym           = Amenity(id: 8,  value: "GYM",            label: "Gym",             emoji: "💪")
    static let furnished     = Amenity(id: 9,  value: "FURNISHED",      label: "Furnished",       emoji: "🛋")
    static let attachedBath  = Amenity(id: 10, value: "ATTACHED_BATH",  label: "Attached bath",   emoji: "🛁")
    static let pool          = Amenity(id: 11, value: "POOL",           label: "Pool",            emoji: "🏊")
    static let wfhReady      = Amenity(id: 12, value: "WFH_READY",      label: "WFH ready",       emoji: "💻")
    static let balcony       = Amenity(id: 13, value: "BALCONY",        label: "Balcony",         emoji: "🪴")

    static let all: [Amenity] = [
        .wifi, .ac, .geyser, .washer, .cctv, .parking, .lift, .gym,
        .furnished, .attachedBath, .pool, .wfhReady, .balcony
    ]

    static func find(by id: Int) -> Amenity? {
        all.first { $0.id == id }
    }
}
