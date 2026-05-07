import Foundation

enum UserStore {
    static let profileKey = "staykin.profile"
    static let snapshotKey = "staykin.onboardingSnapshot"
    static let completeKey = "staykin.onboardingComplete"

    private static var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }

    // MARK: - Registered profile

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

    // MARK: - Mid-flow snapshot (resume after kill)

    static var snapshot: OnboardingSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: snapshotKey) else { return nil }
        return try? JSONDecoder().decode(OnboardingSnapshot.self, from: data)
    }

    static func save(snapshot: OnboardingSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: snapshotKey)
    }

    static func clearSnapshot() {
        UserDefaults.standard.removeObject(forKey: snapshotKey)
    }

    // MARK: - Onboarding completion flag

    static var onboardingComplete: Bool {
        get { UserDefaults.standard.bool(forKey: completeKey) }
        set { UserDefaults.standard.set(newValue, forKey: completeKey) }
    }
}
