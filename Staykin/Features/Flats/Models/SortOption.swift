import Foundation

struct SortOption: Identifiable, Hashable {
    let id: Int
    let value: String
    let label: String
}

extension SortOption {
    static let bestMatch       = SortOption(id: 1, value: "BEST_MATCH",         label: "Best match")
    static let priceLowToHigh  = SortOption(id: 2, value: "PRICE_LOW_TO_HIGH",  label: "Price (low → high)")
    static let priceHighToLow  = SortOption(id: 3, value: "PRICE_HIGH_TO_LOW",  label: "Price (high → low)")
    static let newest          = SortOption(id: 4, value: "NEWEST",             label: "Newest")
    static let mostPopular     = SortOption(id: 5, value: "MOST_POPULAR",       label: "Most popular")

    static let all: [SortOption] = [.bestMatch, .priceLowToHigh, .priceHighToLow, .newest, .mostPopular]

    static func find(by id: Int) -> SortOption? {
        all.first { $0.id == id }
    }
}
