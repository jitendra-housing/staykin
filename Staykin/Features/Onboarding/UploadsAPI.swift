import Foundation

enum UploadsAPI {
    static var baseURL: URL { OnboardingAPI.baseURL }

    static func uploadImage(_ imageData: Data, folder: String = "misc") async throws -> String {
        let url = baseURL.appendingPathComponent("uploads/image")
        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = makeMultipartBody(imageData: imageData, folder: folder, boundary: boundary)

        let (responseData, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
            !(200..<300).contains(http.statusCode) {
            let snippet = String(data: responseData, encoding: .utf8) ?? ""
            throw NSError(
                domain: "UploadsAPI",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "POST /uploads/image failed (\(http.statusCode)): \(snippet)"]
            )
        }

        struct UploadOut: Decodable { let url: String }
        return try JSONDecoder().decode(UploadOut.self, from: responseData).url
    }

    private static func makeMultipartBody(imageData: Data, folder: String, boundary: String) -> Data {
        var body = Data()
        let crlf = "\r\n"

        body.append("--\(boundary)\(crlf)")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\(crlf)")
        body.append("Content-Type: image/jpeg\(crlf)\(crlf)")
        body.append(imageData)
        body.append(crlf)

        body.append("--\(boundary)\(crlf)")
        body.append("Content-Disposition: form-data; name=\"folder\"\(crlf)\(crlf)")
        body.append(folder)
        body.append(crlf)

        body.append("--\(boundary)--\(crlf)")
        return body
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let d = string.data(using: .utf8) { append(d) }
    }
}
