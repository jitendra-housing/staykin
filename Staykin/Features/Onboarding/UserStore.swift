import Foundation

enum UserStore {
    static let profileKey = "staykin.profile"

    private static var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }

    static var saved: UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: profileKey) else { return nil }
        return try? decoder.decode(UserProfile.self, from: data)
    }

    static func save(rawResponse data: Data) {
        UserDefaults.standard.set(data, forKey: profileKey)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: profileKey)
    }
}
