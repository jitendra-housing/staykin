import Foundation

// Heterogeneous entry returned by GET /flatmates/{user_id}.
// Each item is either a team (with members[]) or a standalone user.
enum FlatmateEntry: Decodable, Identifiable {
    case team(team: Team, members: [UserProfile])
    case user(UserProfile)

    var id: String {
        switch self {
        case .team(let team, _): return "team-\(team.id)"
        case .user(let user):    return "user-\(user.id)"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type, team, members, user
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "team":
            let team = try container.decode(Team.self, forKey: .team)
            let members = try container.decode([UserProfile].self, forKey: .members)
            self = .team(team: team, members: members)
        case "user":
            let user = try container.decode(UserProfile.self, forKey: .user)
            self = .user(user)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown flatmate entry type: \(type)"
            )
        }
    }
}
