import Foundation

enum RoomsAPI {
    // GET /rooms?user_id=… — chat rooms the user has access to.
    static func fetchRooms() async throws -> [Room] {
        guard let userId = (UserDefaults.standard.object(forKey: OnboardingAPI.userIdDefaultsKey) as? Int) else {
            throw NSError(
                domain: "RoomsAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "GET /rooms: missing userId"]
            )
        }

        var components = URLComponents(
            url: OnboardingAPI.baseURL.appendingPathComponent("rooms"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [URLQueryItem(name: "user_id", value: String(userId))]

        guard let url = components.url else {
            throw NSError(
                domain: "RoomsAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "GET /rooms: bad URL"]
            )
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
           !(200..<300).contains(http.statusCode) {
            let snippet = String(data: data, encoding: .utf8) ?? ""
            throw NSError(
                domain: "RoomsAPI",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "GET \(url.path) failed (\(http.statusCode)): \(snippet)"]
            )
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([Room].self, from: data)
    }
}
