import Foundation

struct OnboardingSnapshot: Codable {
    var countryCode: String
    var phoneNumber: String
    var userId: Int?

    var photoUrl: String?
    var name: String
    var age: Int?
    var gender: Gender?
    var occupation: Int?
    var city: String

    var intent: UserIntent?

    var areas: Set<Int>
    var budgetMin: Double?
    var budgetMax: Double?
    var bhk: Set<Int>
    var roomType: Int?
    var furnishing: Set<Int>
    var moveIn: Int?
    var vibePrefs: Set<Int>

    var listingLocalityId: Int?
    var listingMonthlyRent: Int?
    var listingBHK: Int?
    var listingFurnishing: Int?
    var listingRoomType: Int?
    var listingFlatmatesNeeded: Int
    var listingGenderPref: Int?
    var listingMoveIn: Int?
    var listingAmenities: Set<Int>
    var flatPhotoUrls: [String]
    var listingIds: [Int]

    var path: [OnboardingRoute]
}

extension OnboardingSnapshot {
    init(data: OnboardingData, path: [OnboardingRoute]) {
        self.countryCode = data.countryCode
        self.phoneNumber = data.phoneNumber
        self.userId = data.userId
        self.photoUrl = data.photoUrl
        self.name = data.name
        self.age = data.age
        self.gender = data.gender
        self.occupation = data.occupation
        self.city = data.city
        self.intent = data.intent
        self.areas = data.areas
        self.budgetMin = data.budgetMin
        self.budgetMax = data.budgetMax
        self.bhk = data.bhk
        self.roomType = data.roomType
        self.furnishing = data.furnishing
        self.moveIn = data.moveIn
        self.vibePrefs = data.vibePrefs
        self.listingLocalityId = data.listingLocalityId
        self.listingMonthlyRent = data.listingMonthlyRent
        self.listingBHK = data.listingBHK
        self.listingFurnishing = data.listingFurnishing
        self.listingRoomType = data.listingRoomType
        self.listingFlatmatesNeeded = data.listingFlatmatesNeeded
        self.listingGenderPref = data.listingGenderPref
        self.listingMoveIn = data.listingMoveIn
        self.listingAmenities = data.listingAmenities
        self.flatPhotoUrls = data.flatPhotoUrls
        self.listingIds = data.listingIds
        self.path = path
    }

    func apply(to data: OnboardingData) {
        data.countryCode = countryCode
        data.phoneNumber = phoneNumber
        data.userId = userId
        data.photoUrl = photoUrl
        data.name = name
        data.age = age
        data.gender = gender
        data.occupation = occupation
        data.city = city
        data.intent = intent
        data.areas = areas
        data.budgetMin = budgetMin
        data.budgetMax = budgetMax
        data.bhk = bhk
        data.roomType = roomType
        data.furnishing = furnishing
        data.moveIn = moveIn
        data.vibePrefs = vibePrefs
        data.listingLocalityId = listingLocalityId
        data.listingMonthlyRent = listingMonthlyRent
        data.listingBHK = listingBHK
        data.listingFurnishing = listingFurnishing
        data.listingRoomType = listingRoomType
        data.listingFlatmatesNeeded = listingFlatmatesNeeded
        data.listingGenderPref = listingGenderPref
        data.listingMoveIn = listingMoveIn
        data.listingAmenities = listingAmenities
        data.flatPhotoUrls = flatPhotoUrls
        data.listingIds = listingIds
    }
}
