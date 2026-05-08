import SwiftUI

enum HomeLanding {
    case flatsList                       // default tab landing
    case flatDetail(FlatDetail)          // deep-link to a flat detail (e.g. user's just-posted listing)
    case flatmates                       // open the flatmates tab
}

struct HomeView: View {
    let onSignOut: () -> Void

    @State private var selectedTab: HomeTab
    @State private var flatsPath: [FlatDetail]
    @State private var profilePath: NavigationPath = NavigationPath()

    init(landing: HomeLanding = .flatsList, onSignOut: @escaping () -> Void) {
        self.onSignOut = onSignOut
        switch landing {
        case .flatsList:
            _selectedTab = State(initialValue: .flats)
            _flatsPath   = State(initialValue: [])
        case .flatDetail(let detail):
            _selectedTab = State(initialValue: .flats)
            _flatsPath   = State(initialValue: [detail])
        case .flatmates:
            _selectedTab = State(initialValue: .flatmates)
            _flatsPath   = State(initialValue: [])
        }
    }

    private var isTabBarVisible: Bool {
        switch selectedTab {
        case .flats:     return flatsPath.isEmpty
        case .flatmates, .chats, .profile: return true
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .flats:     FlatsTabView(path: $flatsPath, onViewMyListings: viewMyListings)
                case .flatmates: FlatmatesTabView()
                case .chats:     FlatmatesCoordinator()
                case .profile:   ProfileTabView(onSignOut: onSignOut, path: $profilePath)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if isTabBarVisible {
                TabBar(selected: $selectedTab)
                    .transition(.move(edge: .bottom))
            }
        }
        .background(Color.bgBase)
        .ignoresSafeArea(edges: .bottom)
        .animation(.easeInOut(duration: 0.2), value: isTabBarVisible)
    }

    private func viewMyListings() {
        selectedTab = .profile
        profilePath.append(ProfileRoute.myListings)
    }
}
