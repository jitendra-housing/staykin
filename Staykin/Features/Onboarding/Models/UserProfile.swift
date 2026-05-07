import Foundation

struct UserProfile: Codable, Equatable {
    let id: Int
    let phone: String?
    let name: String?
    let age: Int?
    let gender: Int?
    let occupation: Int?
    let photoUrl: String?
    let lifestyleTagIds: [Int]?
    let preferredLocalityIds: [Int]?
    let budgetMin: Int?
    let budgetMax: Int?
    let bhkPrefs: [Int]?
    let roomTypePref: Int?
    let furnishingPrefs: [Int]?
    let moveInPref: Int?
    let moveInDate: String?
    let genderPref: Int?
    let listingIds: [Int]?

    // Optional. Backend doesn't yet return this on UserOut; once it does
    // (vibe_score: int 0-100), both the Flatmates swipe card and the chat
    // header light up automatically via Flatmate(profile:).
    let vibeScore: Int?
}
