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
    let vibeScore: Int?
    let totalResidents: Int?
}

extension Listing {
    func toFlat() -> Flat {
        Flat(
            id: id,
            typeId: FlatType.privateRoom.id,
            locality: Area.find(by: localityId)?.name ?? "—",
            rent: monthlyRent,
            score: vibeScore ?? 80,
            amenityIds: amenities ?? [],
            photoURL: photos?.first,
            photoHue: 280,
            photoHue2: 320,
            photoEmoji: "🏠",
            verified: false,
            availableNow: moveIn == 1,
            totalResidents: totalResidents
        )
    }

    func toFlatDetail(isOwnListing: Bool = false) -> FlatDetail {
        let flatPhotos: [FlatPhoto] = (photos ?? []).enumerated().map { idx, url in
            FlatPhoto(
                id: idx,
                url: url,
                placeholderHue: 280,
                placeholderHue2: 320,
                placeholderEmoji: "🏠"
            )
        }
        let total = flatmatesNeeded + 1
        return FlatDetail(
            id: id,
            typeId: FlatType.privateRoom.id,
            locality: Area.find(by: localityId)?.name ?? "—",
            addressLine: "",
            rent: monthlyRent,
            bhkId: bhk,
            furnishingId: furnishing,
            areaSqft: 0,
            verified: false,
            availableNow: moveIn == 1,
            score: 80,
            photos: flatPhotos,
            amenityIds: amenities ?? [],
            flatmates: [],
            combinedMatch: CombinedMatch(score: 0, summary: "", participants: []),
            slots: FlatSlots(total: total, filled: 1),
            privateRoom: nil,
            about: "",
            isOwnListing: isOwnListing,
            ownerUserId: ownerUserId
        )
    }
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
            "room_type": data.listingRoomType ?? NSNull(),
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

    static func listListings(userId: Int) async throws -> [Listing] {
        var components = URLComponents(url: baseURL.appendingPathComponent("listings"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "user_id", value: String(userId)),
            URLQueryItem(name: "viewer_id", value: String(userId))
        ]
        let url = components.url!
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
                userInfo: [NSLocalizedDescriptionKey: "GET /listings failed (\(http.statusCode)): \(snippet)"]
            )
        }

        print()
        return try decoder.decode([Listing].self, from: responseData)
    }

    static func getListing(id: Int, viewerId: Int? = nil) async throws -> Listing {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("listings/\(id)"),
            resolvingAgainstBaseURL: false
        )!
        if let viewerId {
            components.queryItems = [URLQueryItem(name: "viewer_id", value: String(viewerId))]
        }
        let url = components.url!
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
