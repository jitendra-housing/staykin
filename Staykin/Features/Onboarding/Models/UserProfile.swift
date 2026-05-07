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
}
