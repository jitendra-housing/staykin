import Foundation

enum ListingsAPI {
    static var baseURL: URL { OnboardingAPI.baseURL }

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

        struct ListingOut: Decodable { let id: Int }
        return try JSONDecoder().decode(ListingOut.self, from: responseData).id
    }
}
