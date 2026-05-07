import Foundation

struct Listing: Codable, Hashable {
    let id: Int
    let ownerUserId: Int
    let localityId: Int
    let monthlyRent: Int
    let bhk: Int
    let furnishing: Int
    let flatmatesNeeded: Int
    let genderPref: Int
    let amenities: [Int]?
    let moveIn: Int
    let photos: [String]?
}

enum ListingsAPI {
    static var baseURL: URL { OnboardingAPI.baseURL }

    private static var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }

    @discardableResult
    static func createListing(_ data: OnboardingData) async throws -> Int {
        guard let ownerUserId = data.userId
            ?? (UserDefaults.standard.object(forKey: OnboardingAPI.userIdDefaultsKey) as? Int)
        else {
            throw NSError(
                domain: "ListingsAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "POST /listings: missing owner_user_id"]
            )
        }

        let body: [String: Any] = [
            "owner_user_id": ownerUserId,
            "locality_id": data.listingLocalityId ?? NSNull(),
            "monthly_rent": data.listingMonthlyRent ?? NSNull(),
            "bhk": data.listingBHK ?? NSNull(),
            "furnishing": data.listingFurnishing ?? NSNull(),
            "flatmates_needed": data.listingFlatmatesNeeded,
            "gender_pref": data.listingGenderPref ?? NSNull(),
            "move_in": data.listingMoveIn ?? NSNull(),
            "amenities": Array(data.listingAmenities).sorted(),
            "photos": data.flatPhotoUrls
        ]

        let url = baseURL.appendingPathComponent("listings")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (responseData, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
            !(200..<300).contains(http.statusCode) {
            let snippet = String(data: responseData, encoding: .utf8) ?? ""
            throw NSError(
                domain: "ListingsAPI",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "POST /listings failed (\(http.statusCode)): \(snippet)"]
            )
        }

        return try decoder.decode(Listing.self, from: responseData).id
    }

    static func getListing(id: Int) async throws -> Listing {
        let url = baseURL.appendingPathComponent("listings/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")

        let (responseData, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
            !(200..<300).contains(http.statusCode) {
            let snippet = String(data: responseData, encoding: .utf8) ?? ""
            throw NSError(
                domain: "ListingsAPI",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "GET /listings/\(id) failed (\(http.statusCode)): \(snippet)"]
            )
        }

        return try decoder.decode(Listing.self, from: responseData)
    }
}
