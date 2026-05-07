import SwiftUI

struct HomeView: View {
    @State private var selectedTab: HomeTab = .flats

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .flats:     FlatsTabView()
                case .flatmates: FlatmatesTabPlaceholder()
                case .chats:     ChatsTabPlaceholder()
                case .profile:   ProfileTabPlaceholder()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            TabBar(selected: $selectedTab)
        }
        .background(Color.bgBase)
        .ignoresSafeArea(edges: .bottom)
    }
}
