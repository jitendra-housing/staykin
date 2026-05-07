import Foundation

// Localities supported in the launch city (Gurgaon only for v1).
struct Area: Identifiable, Hashable {
    let id: Int
    let name: String
}

extension Area {
    static let allInGurgaon: [Area] = [
        .init(id: 1, name: "DLF Phase 1"),
        .init(id: 2, name: "Sector 46"),
        .init(id: 3, name: "Cyber City"),
        .init(id: 4, name: "Manesar"),
        .init(id: 5, name: "Golf Course Road"),
        .init(id: 6, name: "Sushant Lok 1"),
        .init(id: 7, name: "South City 1")
    ]

    static func find(by id: Int) -> Area? {
        allInGurgaon.first { $0.id == id }
    }
}
