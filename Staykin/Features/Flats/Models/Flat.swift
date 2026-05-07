import Foundation

// Compact shape returned by GET /flats — used by the Flats list row.
struct Flat: Identifiable, Hashable {
    let id: Int
    let typeId: Int                // FlatType.id
    let locality: String
    let rent: Int                  // INR rupees
    let score: Int                 // 0–100, personalised match
    let amenityIds: [Int]          // Amenity.id values (top 3–4)
    let photoURL: String?
    let photoHue: Double           // placeholder gradient hue, 0–360
    let photoHue2: Double
    let photoEmoji: String         // placeholder emoji
    let verified: Bool
    let availableNow: Bool
    var totalResidents: Int? = 1

    var type: FlatType { FlatType.find(by: typeId) ?? .privateRoom }
    var amenities: [Amenity] { amenityIds.compactMap(Amenity.find(by:)) }
    var rentLabel: String { "₹\(Int(Double(rent) / 1000))K" }
}

// Combined "you + existing flatmates" match metric on the detail screen.
struct CombinedMatch: Hashable {
    let score: Int                 // 0–100
    let summary: String            // e.g. "Strong vibe"
    let participants: [String]     // e.g. ["You", "Aarav", "Priya"]
}

// Slot accounting on the detail screen — drives "X spot left" + empty row.
struct FlatSlots: Hashable {
    let total: Int
    let filled: Int
    var open: Int { total - filled }
}

struct PrivateRoomInfo: Hashable {
    let rentShare: Int             // ₹ per slot
    let availableNow: Bool
}

struct FlatPhoto: Identifiable, Hashable {
    let id: Int
    let url: String?
    let placeholderHue: Double
    let placeholderHue2: Double
    let placeholderEmoji: String
}

// Full shape returned by GET /flats/:id — used by the Flat Detail screen.
struct FlatDetail: Identifiable, Hashable {
    let id: Int
    let typeId: Int
    let locality: String
    let addressLine: String
    let rent: Int                  // total flat rent
    let bhkId: Int                 // BHK.id
    let furnishingId: Int          // Furnishing.id
    let areaSqft: Int
    let verified: Bool
    let availableNow: Bool
    let score: Int

    let photos: [FlatPhoto]
    let amenityIds: [Int]
    let flatmates: [Flatmate]
    let combinedMatch: CombinedMatch
    let slots: FlatSlots
    let privateRoom: PrivateRoomInfo?
    let about: String
    var isOwnListing: Bool = false
    var ownerUserId: Int? = nil

    var type: FlatType { FlatType.find(by: typeId) ?? .privateRoom }
    var bhk: BHK { BHK.find(by: bhkId) ?? .twoBHK }
    var furnishing: Furnishing { Furnishing.find(by: furnishingId) ?? .furnished }
    var amenities: [Amenity] { amenityIds.compactMap(Amenity.find(by:)) }
    var rentLabel: String { "₹\(Int(Double(rent) / 1000))K" }
}
