import SwiftUI

struct HomeView: View {
    @State private var selectedTab: HomeTab = .flats
    @State private var flatsPath: [Flat] = []

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
                case .flats:     FlatsTabView(path: $flatsPath)
                case .flatmates: FlatmatesTabPlaceholder()
                case .chats:     ChatsTabPlaceholder()
                case .profile:   ProfileTabPlaceholder()
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
}
