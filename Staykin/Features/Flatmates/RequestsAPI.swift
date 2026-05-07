import Foundation

// Lightweight subset of /requests RequestDetailOut — we only need the saved
// id + status for client UI; rest is server bookkeeping.
struct RequestOut: Decodable, Hashable, Identifiable {
    let id: Int
    let fromUserId: Int
    let targetKind: Int           // 1 = user, 2 = team
    let targetUserId: Int?
    let targetTeamId: Int?
    let status: Int               // server-defined enum (1 pending / 2 accepted / 3 declined)
    let createdAt: String
}

enum RequestsAPI {
    enum TargetKind: Int {
        case user = 1
        case team = 2
    }

    // MARK: - POST /requests

    // Fired when the user swipes right on a flatmate card or taps Enquire on a flat detail.
    @discardableResult
    static func sendRequest(targetKind: TargetKind, targetId: Int) async throws -> RequestOut {
        guard let fromUserId = UserDefaults.standard.object(forKey: OnboardingAPI.userIdDefaultsKey) as? Int else {
            throw NSError(
                domain: "RequestsAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "POST /requests: missing userId in defaults"]
            )
        }

        let url = OnboardingAPI.baseURL.appendingPathComponent("requests")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let body: [String: Any] = [
            "from_user_id": fromUserId,
            "target_kind":  targetKind.rawValue,
            "target_id":    targetId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

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
        return try decoder.decode(RequestOut.self, from: data)
    }

    // MARK: - GET /requests/sent

    // Optional status filter mirrors backend's int-based enum (1/2/3).
    static func fetchSent(status: Int? = nil) async throws -> [RequestOut] {
        guard let userId = UserDefaults.standard.object(forKey: OnboardingAPI.userIdDefaultsKey) as? Int else {
            throw NSError(
                domain: "RequestsAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "GET /requests/sent: missing userId in defaults"]
            )
        }

        var components = URLComponents(
            url: OnboardingAPI.baseURL.appendingPathComponent("requests/sent"),
            resolvingAgainstBaseURL: false
        )!
        var query: [URLQueryItem] = [.init(name: "user_id", value: String(userId))]
        if let status { query.append(.init(name: "status", value: String(status))) }
        components.queryItems = query

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
           !(200..<300).contains(http.statusCode) {
            let snippet = String(data: data, encoding: .utf8) ?? ""
            throw NSError(
                domain: "RequestsAPI",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "GET /requests/sent failed (\(http.statusCode)): \(snippet)"]
            )
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([RequestOut].self, from: data)
    }

    // MARK: - GET /requests/received

    // Pending flatmate requests sent TO the current user.
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

    // MARK: - POST /requests/{id}/accept · /reject

    @discardableResult
    static func accept(requestId: Int) async throws -> RequestActionResponse {
        try await postDecision(requestId: requestId, action: "accept")
    }

    @discardableResult
    static func reject(requestId: Int) async throws -> RequestActionResponse {
        try await postDecision(requestId: requestId, action: "reject")
    }

    private static func postDecision(requestId: Int, action: String) async throws -> RequestActionResponse {
        guard let userId = UserDefaults.standard.object(forKey: OnboardingAPI.userIdDefaultsKey) as? Int else {
            throw NSError(
                domain: "RequestsAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "POST /requests/\(requestId)/\(action): missing userId in defaults"]
            )
        }

        let url = OnboardingAPI.baseURL.appendingPathComponent("requests/\(requestId)/\(action)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["user_id": userId]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

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
