import Foundation

enum RequestsAPI {
    // GET /requests/received?user_id=… — pending flatmate requests sent to you.
    static func fetchReceived() async throws -> [ReceivedRequest] {
        guard let userId = (UserDefaults.standard.object(forKey: OnboardingAPI.userIdDefaultsKey) as? Int) else {
            throw NSError(
                domain: "RequestsAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "GET /requests/received: missing userId"]
            )
        }

        var components = URLComponents(
            url: OnboardingAPI.baseURL.appendingPathComponent("requests/received"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [URLQueryItem(name: "user_id", value: String(userId))]

        guard let url = components.url else {
            throw NSError(
                domain: "RequestsAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "GET /requests/received: bad URL"]
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
                domain: "RequestsAPI",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "GET \(url.path) failed (\(http.statusCode)): \(snippet)"]
            )
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([ReceivedRequest].self, from: data)
    }

    // POST /requests/{request_id}/accept
    @discardableResult
    static func accept(requestId: Int) async throws -> RequestActionResponse {
        try await postDecision(requestId: requestId, action: "accept")
    }

    // POST /requests/{request_id}/reject
    @discardableResult
    static func reject(requestId: Int) async throws -> RequestActionResponse {
        try await postDecision(requestId: requestId, action: "reject")
    }

    private static func postDecision(requestId: Int, action: String) async throws -> RequestActionResponse {
        let url = OnboardingAPI.baseURL.appendingPathComponent("requests/\(requestId)/\(action)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
           !(200..<300).contains(http.statusCode) {
            let snippet = String(data: data, encoding: .utf8) ?? ""
            throw NSError(
                domain: "RequestsAPI",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "POST \(url.path) failed (\(http.statusCode)): \(snippet)"]
            )
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(RequestActionResponse.self, from: data)
    }
}
