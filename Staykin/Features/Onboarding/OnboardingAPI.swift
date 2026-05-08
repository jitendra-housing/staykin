import Foundation

enum OnboardingAPI {
    static let baseURL = URL(string: "https://somatopleural-diann-comfortingly.ngrok-free.dev")!
    static let userIdDefaultsKey = "staykin.userId"

    private static let isoDate: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    @discardableResult
    static func submitProfile(_ data: OnboardingData) async throws -> UserProfile {
        let url = baseURL.appendingPathComponent("profile")
        let responseData = try await sendProfile(method: "POST", url: url, data: data)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let profile: UserProfile
        do {
            profile = try decoder.decode(UserProfile.self, from: responseData)
        } catch {
            let snippet = String(data: responseData, encoding: .utf8) ?? ""
            throw NSError(
                domain: "OnboardingAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "POST /profile: cannot decode response: \(snippet)"]
            )
        }

        UserStore.save(rawResponse: responseData)
        UserDefaults.standard.set(profile.id, forKey: userIdDefaultsKey)
        return profile
    }

    /// Looks up an existing profile by phone. Returns the user_id if registered;
    /// nil if 404 (not found) or if the backend returns the -1 sentinel.
    static func lookupUserId(byPhone phone: String) async throws -> Int? {
        let url = baseURL.appendingPathComponent("profile/by-phone/\(phone)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")

        let (responseData, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse {
            if http.statusCode == 404 { return nil }
            if !(200..<300).contains(http.statusCode) {
                let snippet = String(data: responseData, encoding: .utf8) ?? ""
                throw NSError(
                    domain: "OnboardingAPI",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "GET /profile/by-phone failed (\(http.statusCode)): \(snippet)"]
                )
            }
        }

        struct ByPhoneOut: Decodable { let userId: Int }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let out = try decoder.decode(ByPhoneOut.self, from: responseData)
        return out.userId == -1 ? nil : out.userId
    }

    /// Fetches a profile by user id without persisting. Use for arbitrary users (e.g. listing owners).
    /// Pass `viewerId` to have the backend compute `vibe_score` against that viewer.
    static func getProfile(userId: Int, viewerId: Int? = nil) async throws -> (UserProfile, Data) {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("profile/\(userId)"),
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
                domain: "OnboardingAPI",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "GET /profile/\(userId) failed (\(http.statusCode)): \(snippet)"]
            )
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let profile = try decoder.decode(UserProfile.self, from: responseData)
            return (profile, responseData)
        } catch {
            let snippet = String(data: responseData, encoding: .utf8) ?? ""
            throw NSError(
                domain: "OnboardingAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "GET /profile/\(userId): cannot decode response: \(snippet)"]
            )
        }
    }

    /// Fetches the current user's profile and persists the response. Use only for "me".
    @discardableResult
    static func fetchProfile(userId: Int) async throws -> UserProfile {
        let (profile, raw) = try await getProfile(userId: userId)
        UserStore.save(rawResponse: raw)
        UserDefaults.standard.set(profile.id, forKey: userIdDefaultsKey)
        return profile
    }

    static func patchProfile(_ data: OnboardingData) async throws {
        guard let userId = data.userId
            ?? (UserDefaults.standard.object(forKey: userIdDefaultsKey) as? Int)
        else {
            throw NSError(
                domain: "OnboardingAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "PATCH /profile/{id}: missing userId"]
            )
        }
        let url = baseURL.appendingPathComponent("profile/\(userId)")
        _ = try await sendProfile(method: "PATCH", url: url, data: data)
    }

    private static func sendProfile(method: String, url: URL, data: OnboardingData) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.httpBody = try JSONSerialization.data(withJSONObject: makeBody(data, isPatch: method == "PATCH"), options: [])

        let (responseData, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
            !(200..<300).contains(http.statusCode) {
            let snippet = String(data: responseData, encoding: .utf8) ?? ""
            throw NSError(
                domain: "OnboardingAPI",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "\(method) \(url.path) failed (\(http.statusCode)): \(snippet)"]
            )
        }
        return responseData
    }

    private static func makeBody(_ data: OnboardingData, isPatch: Bool = false) -> [String: Any] {
        var body: [String: Any] = [
            "age": data.age ?? NSNull(),
            "gender": data.gender?.id ?? NSNull(),
            "occupation": data.occupation ?? NSNull(),
            "photo_url": data.photoUrl ?? "",
            "lifestyle_tag_ids": Array(data.vibePrefs).sorted(),
            "preferred_locality_ids": Array(data.areas).sorted(),
            "budget_min": data.budgetMin.map { Int($0) } ?? NSNull(),
            "budget_max": data.budgetMax.map { Int($0) } ?? NSNull(),
            "bhk_prefs": Array(data.bhk).sorted(),
            "furnishing_prefs": Array(data.furnishing).sorted(),
            "gender_pref": data.gender?.id ?? NSNull()
        ]
        // Skip empty defaults on PATCH so a partial update (e.g. vibe-only) doesn't
        // overwrite phone/name with "" or silently reset the user's move-in date.
        let trimmedName = data.name.trimmingCharacters(in: .whitespaces)
        if !isPatch || !data.phoneNumber.isEmpty { body["phone"] = data.phoneNumber }
        if !isPatch || !trimmedName.isEmpty { body["name"] = trimmedName }
        if !isPatch { body["move_in_date"] = isoDate.string(from: Date()) }
        if let roomType = data.roomType { body["room_type_pref"] = roomType }
        if let moveIn = data.moveIn { body["move_in_pref"] = moveIn }
        return body
    }
}
