import SwiftUI

struct FlatsFilter: Equatable {
    var typeIds: Set<Int> = []      // FlatType.id values
    var verifiedOnly: Bool = false
    var availableNow: Bool = false

    var isAllActive: Bool {
        typeIds.isEmpty && !verifiedOnly && !availableNow
    }

    func matches(_ flat: Flat) -> Bool {
        if !typeIds.isEmpty && !typeIds.contains(flat.typeId) { return false }
        if verifiedOnly && !flat.verified { return false }
        if availableNow && !flat.availableNow { return false }
        return true
    }
}

struct FlatsTabView: View {
    @Binding var path: [FlatDetail]
    @State private var filter = FlatsFilter()
    @State private var showPostSpace = false
    @State private var listings: [Listing] = []

    private var visibleListings: [Listing] {
        listings.filter { filter.matches($0.toFlat()) }
    }
    private var visibleCount: Int { visibleListings.count }

    private var currentUserId: Int? {
        UserStore.saved?.id
            ?? (UserDefaults.standard.object(forKey: OnboardingAPI.userIdDefaultsKey) as? Int)
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                header
                filterChips
                resultBar
                list
            }
            .background(Color.bgBase)
            .navigationDestination(for: FlatDetail.self) { detail in
                FlatDetailView(detail: detail, onBack: pop)
            }
        }
        .tint(.primaryPurple)
        .fullScreenCover(isPresented: $showPostSpace) {
            PostSpaceCoordinator(onDismiss: { showPostSpace = false })
        }
        .task { await loadListings() }
    }

    private func loadListings() async {
        guard let userId = currentUserId else { return }
        do {
            listings = try await ListingsAPI.listListings(userId: userId)
        } catch {
            print("listListings failed: \(error)")
        }
    }

    private func pop() {
        if !path.isEmpty { path.removeLast() }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Staykin")
                .font(.custom("Outfit", size: 22).weight(.heavy))
                .gradientForeground(.brand)
                .tracking(-0.5)

            Spacer()

            Button {
                showPostSpace = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .heavy))
                    Text("Post your Space")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(Color(hex: "C4B5FD"))
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background(Color.primaryPurple.opacity(0.08))
                .clipShape(Capsule())
                .overlay(
                    Capsule().strokeBorder(Color.primaryPurple.opacity(0.35), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .frame(height: 56)
    }

    // MARK: - Filter chip row

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip("All", active: filter.isAllActive) { filter = FlatsFilter() }

                ForEach(FlatType.all) { type in
                    chip(type.label, active: filter.typeIds.contains(type.id)) {
                        toggle(type.id, in: \.typeIds)
                    }
                }

                chip("Verified", active: filter.verifiedOnly) { filter.verifiedOnly.toggle() }
                chip("Available now", active: filter.availableNow) { filter.availableNow.toggle() }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 14)
    }

    private func chip(_ label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(active ? .white : Color.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Group {
                        if active {
                            LinearGradient.brand
                        } else {
                            Color.clear
                        }
                    }
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule().strokeBorder(active ? Color.clear : Color.cardBorder, lineWidth: 1)
                )
                .fixedSize()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Result count + sort

    private var resultBar: some View {
        HStack {
            HStack(spacing: 4) {
                Text("\(visibleCount) flats")
                    .font(.caption1.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                Text("in your vibe")
                    .font(.caption1)
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer()
            Text("↓ Best match")
                .font(.caption1)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 6)
    }

    // MARK: - List

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(visibleListings, id: \.id) { listing in
                    let isOwn = listing.ownerUserId == currentUserId
                    NavigationLink(value: listing.toFlatDetail(isOwnListing: isOwn)) {
                        FlatListRow(flat: listing.toFlat())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Helpers

    private func toggle(_ value: Int, in keyPath: WritableKeyPath<FlatsFilter, Set<Int>>) {
        if filter[keyPath: keyPath].contains(value) {
            filter[keyPath: keyPath].remove(value)
        } else {
            filter[keyPath: keyPath].insert(value)
        }
    }
}
