import Foundation

enum FlatmatesAPI {
    // GET /flatmates/{user_id} — returns mixed array of team+members and standalone users.
    static func fetchFlatmates() async throws -> [FlatmateEntry] {
        guard let userId = (UserDefaults.standard.object(forKey: OnboardingAPI.userIdDefaultsKey) as? Int) else {
            throw NSError(
                domain: "FlatmatesAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "GET /flatmates/{id}: missing userId"]
            )
        }

        var components = URLComponents(
            url: OnboardingAPI.baseURL.appendingPathComponent("flatmates/\(userId)"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [URLQueryItem(name: "viewer_id", value: String(userId))]
        let url = components.url!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
           !(200..<300).contains(http.statusCode) {
            let snippet = String(data: data, encoding: .utf8) ?? ""
            throw NSError(
                domain: "FlatmatesAPI",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "GET \(url.path) failed (\(http.statusCode)): \(snippet)"]
            )
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([FlatmateEntry].self, from: data)
    }
}
