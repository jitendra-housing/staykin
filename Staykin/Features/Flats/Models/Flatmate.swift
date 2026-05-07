import Foundation

enum FlatmateRole: String, Hashable {
    case poster   = "POSTER"
    case flatmate = "FLATMATE"
    case host     = "HOST"

    var badgeText: String {
        switch self {
        case .poster:   return "THEIR VIBE"
        case .flatmate: return "FLATMATE"
        case .host:     return "HOST"
        }
    }
}

struct LookingForItem: Hashable {
    let label: String
    let value: String
}

struct Flatmate: Identifiable, Hashable {
    let id: Int
    let name: String
    let age: Int
    let role: FlatmateRole
    let job: String
    let emoji: String?
    let avatarURL: String?
    let avatarHue: Double          // 0–360, used by the photo placeholder
    let avatarHue2: Double
    let matchPct: Int              // 0–100
    let vibePrefIds: [Int]         // VibePref.id values
    let bio: String
    let lookingFor: [LookingForItem]

    var vibePrefs: [VibePref] {
        vibePrefIds.compactMap(VibePref.find(by:))
    }

    var displayTags: [String] {
        vibePrefs.map { "\($0.emoji) \($0.label)" }
    }
}
