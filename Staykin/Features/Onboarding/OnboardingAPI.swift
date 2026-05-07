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

    @discardableResult
    static func fetchProfile(userId: Int) async throws -> UserProfile {
        let url = baseURL.appendingPathComponent("profile/\(userId)")
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
        let profile: UserProfile
        do {
            profile = try decoder.decode(UserProfile.self, from: responseData)
        } catch {
            let snippet = String(data: responseData, encoding: .utf8) ?? ""
            throw NSError(
                domain: "OnboardingAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "GET /profile/\(userId): cannot decode response: \(snippet)"]
            )
        }

        UserStore.save(rawResponse: responseData)
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
        request.httpBody = try JSONSerialization.data(withJSONObject: makeBody(data), options: [])

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

    private static func makeBody(_ data: OnboardingData) -> [String: Any] {
        var body: [String: Any] = [
            "phone": data.phoneNumber,
            "name": data.name.trimmingCharacters(in: .whitespaces),
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
            "move_in_date": isoDate.string(from: Date()),
            "gender_pref": data.gender?.id ?? NSNull()
        ]
        if let roomType = data.roomType { body["room_type_pref"] = roomType }
        if let moveIn = data.moveIn { body["move_in_pref"] = moveIn }
        return body
    }
}
