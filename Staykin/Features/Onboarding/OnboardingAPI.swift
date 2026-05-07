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
    static func submitProfile(_ data: OnboardingData) async throws -> Int {
        let url = baseURL.appendingPathComponent("profile")

        var body: [String: Any] = [
            "phone": data.phoneNumber,
            "name": data.name.trimmingCharacters(in: .whitespaces),
            "age": data.age ?? NSNull(),
            "gender": data.gender?.id ?? NSNull(),
            "occupation": data.occupation ?? NSNull(),
            "photo_url": "",
            "lifestyle_tag_ids": Array(data.vibePrefs).sorted(),
            "preferred_locality_ids": Array(data.areas).sorted(),
            "budget_min": Int(data.budgetMin),
            "budget_max": Int(data.budgetMax),
            "bhk_prefs": Array(data.bhk).sorted(),
            "furnishing_prefs": Array(data.furnishing).sorted(),
            "move_in_date": isoDate.string(from: Date()),
            "gender_pref": data.gender?.id ?? NSNull()
        ]
        if let roomType = data.roomType { body["room_type_pref"] = roomType }
        if let moveIn = data.moveIn { body["move_in_pref"] = moveIn }

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
                domain: "OnboardingAPI",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "POST /profile failed (\(http.statusCode)): \(snippet)"]
            )
        }

        guard
            let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
            let userId = (json["id"] as? Int) ?? (json["id"] as? NSNumber)?.intValue
        else {
            let snippet = String(data: responseData, encoding: .utf8) ?? ""
            throw NSError(
                domain: "OnboardingAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "POST /profile: missing 'id' in response: \(snippet)"]
            )
        }

        UserDefaults.standard.set(userId, forKey: userIdDefaultsKey)
        return userId
    }
}
