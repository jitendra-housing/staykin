import Foundation
import Observation

enum UserIntent: String, CaseIterable, Hashable {
    case moveIntoFlat       // Find an existing flat with rooms available
    case fillRoomsInMyFlat  // I have a place, find flatmates to fill it
    case teamUpToRent       // Find your squad, then hunt together
}

enum Gender: String, CaseIterable, Hashable {
    case female = "Female"
    case male = "Male"
    case nonBinary = "Non-binary"
    case preferNotToSay = "Prefer not to say"
}

enum BHK: String, CaseIterable, Hashable {
    case oneBHK = "1BHK"
    case twoBHK = "2BHK"
    case threeBHK = "3BHK"
    case studio = "Studio"
}

enum RoomType: String, CaseIterable, Hashable {
    case singleRoom = "🛏 Single Room"
    case sharing    = "👯 Sharing"
    case either     = "🤷 Either"
}

enum Furnishing: String, CaseIterable, Hashable {
    case furnished   = "Furnished"
    case semi        = "Semi"
    case unfurnished = "Unfurnished"
}

enum MoveInTimeline: String, CaseIterable, Hashable {
    case asap          = "ASAP 🚀"
    case withinMonth   = "Within 1 month"
    case oneToThree    = "1–3 months"
}

@Observable
final class OnboardingData {
    // Auth
    var countryCode: String = "+91"
    var phoneNumber: String = ""
    var otpCode: String = ""

    // Basic profile
    var photoData: Data? = nil
    var name: String = ""
    var age: Int? = nil
    var gender: Gender? = nil
    var occupation: String = ""
    var city: String = ""

    // Intent
    var intent: UserIntent? = nil

    // Flat prefs (Step 1 of 2)
    var areas: Set<String> = []
    var budgetMin: Double = 15_000
    var budgetMax: Double = 30_000
    var bhk: Set<BHK> = []
    var roomType: RoomType? = nil
    var furnishing: Set<Furnishing> = []
    var moveIn: MoveInTimeline? = nil

    // Vibe prefs (Step 2 of 2) — emoji preferences, min 5
    var vibePrefs: Set<String> = []
}
