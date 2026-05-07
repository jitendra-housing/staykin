import SwiftUI

struct MyListingsScreen: View {
    let listingIds: [Int]
    let onBack: () -> Void

    @State private var listings: [Listing] = []
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
        .task { await loadListings() }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.bgCard)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Color.cardBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)
            Text("My listings")
                .font(.heading2)
                .foregroundStyle(Color.textPrimary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if isLoading {
            VStack {
                Spacer()
                ProgressView().tint(Color.primaryPurple)
                Spacer()
            }
        } else if listings.isEmpty {
            VStack(spacing: 8) {
                Spacer()
                Text("No listings yet")
                    .font(.bodyLg.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                Text("Post your space to find flatmates who vibe with your home.")
                    .font(.caption1)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(listings, id: \.id) { listing in
                        NavigationLink(value: listing.toFlatDetail(isOwnListing: true)) {
                            FlatListRow(flat: listing.toFlat(), hideMatch: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Fetch

    private func loadListings() async {
        isLoading = true
        defer { isLoading = false }
        guard !listingIds.isEmpty else { listings = []; return }

        var fetched: [Listing] = []
        await withTaskGroup(of: Listing?.self) { group in
            for id in listingIds {
                group.addTask {
                    try? await ListingsAPI.getListing(id: id)
                }
            }
            for await result in group {
                if let listing = result {
                    fetched.append(listing)
                }
            }
        }
        listings = fetched.sorted { $0.id > $1.id }
    }
}
