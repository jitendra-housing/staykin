import Foundation
import Observation

enum UserIntent: String, CaseIterable, Hashable, Codable {
    case moveIntoFlat       // Find an existing flat with rooms available
    case fillRoomsInMyFlat  // I have a place, find flatmates to fill it
    case teamUpToRent       // Find your squad, then hunt together
}

enum Gender: String, CaseIterable, Hashable, Codable {
    case male = "Male"
    case female = "Female"
    case other = "Other"

    var id: Int {
        switch self {
        case .male: return 1
        case .female: return 2
        case .other: return 3
        }
    }
}

@Observable
final class OnboardingData {
    // Server-issued user id (set after POST /profile succeeds)
    var userId: Int? = nil

    // Auth
    var countryCode: String = "+91"
    var phoneNumber: String = ""
    var otpCode: String = ""

    // Basic profile
    var photoData: Data? = nil
    var photoUrl: String? = nil      // Server URL after /uploads/image
    var name: String = ""
    var age: Int? = nil
    var gender: Gender? = nil
    var occupation: Int? = nil       // Occupation.id
    var city: String = "Gurgaon"   // launch city — single value for v1

    // Intent
    var intent: UserIntent? = nil

    // Flat prefs (Step 1 of 2)
    var areas: Set<Int> = []       // Area.id values
    var budgetMin: Double = 15_000
    var budgetMax: Double = 30_000
    var bhk: Set<Int> = []          // BHK.id values
    var roomType: Int? = nil        // RoomType.id
    var furnishing: Set<Int> = []   // Furnishing.id values
    var moveIn: Int? = nil          // MoveInTimeline.id

    // Vibe prefs (Step 2 of 2) — VibePref.id values, min 5
    var vibePrefs: Set<Int> = []

    // Post-listing flow — fields collected on FlatDetailsScreen + PhotosScreen for POST /listings
    var listingLocalityId: Int? = nil      // locality_id
    var listingMonthlyRent: Int? = nil     // monthly_rent
    var listingBHK: Int? = nil             // bhk
    var listingFurnishing: Int? = nil      // furnishing
    var listingFlatmatesNeeded: Int = 1    // flatmates_needed (1..5)
    var listingGenderPref: Int? = nil      // gender_pref
    var listingMoveIn: Int? = nil          // move_in
    var listingAmenities: Set<Int> = []    // amenities
    var flatPhotoUrls: [String] = []       // photos (URLs from /uploads/image)
}
