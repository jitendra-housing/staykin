import Foundation

enum HomeTab: Hashable, CaseIterable {
    case flats
    case flatmates
    case chats
    case profile

    var label: String {
        switch self {
        case .flats:     return "Flats"
        case .flatmates: return "Flatmates"
        case .chats:     return "Chats"
        case .profile:   return "Profile"
        }
    }

    var iconName: String {
        switch self {
        case .flats:     return "house"
        case .flatmates: return "person.2"
        case .chats:     return "bubble.left"
        case .profile:   return "person.crop.circle"
        }
    }
}
