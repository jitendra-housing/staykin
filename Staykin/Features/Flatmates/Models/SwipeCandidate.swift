import Foundation

// One card in the Flatmates swipe deck. Preserves the team-vs-user identity
// from GET /flatmates/{user_id} so POST /requests can target with the right
// target_kind (2 = team, 1 = user) instead of always flattening to user.
enum SwipeCandidate: Identifiable {
    case team(Team, members: [UserProfile])
    case user(UserProfile)

    var id: String {
        switch self {
        case .team(let t, _): return "team-\(t.id)"
        case .user(let u):    return "user-\(u.id)"
        }
    }

    // Visual representation — first member for teams, the user themselves
    // for individual cards. (Team-aware UI variant TBD.)
    var displayFlatmate: Flatmate {
        switch self {
        case .team(_, let members):
            // Members must be non-empty per backend contract.
            return Flatmate(profile: members[0])
        case .user(let user):
            return Flatmate(profile: user)
        }
    }

    // What to send on swipe-right. Team → kind=2 with team.id;
    // user → kind=1 with user.id.
    var requestTarget: (kind: RequestsAPI.TargetKind, id: Int) {
        switch self {
        case .team(let team, _): return (.team, team.id)
        case .user(let user):    return (.user, user.id)
        }
    }

    // Display name for the toast after a successful swipe.
    var displayName: String {
        switch self {
        case .team(let team, let members):
            return team.name ?? members.first?.name ?? "Squad"
        case .user(let user):
            return user.name ?? "Flatmate"
        }
    }

    // Member count — for team cards we may want to show "+N more" later.
    var memberCount: Int {
        switch self {
        case .team(_, let members): return members.count
        case .user:                 return 1
        }
    }
}
