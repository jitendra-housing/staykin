import Foundation

struct BHK: Identifiable, Hashable {
    let id: Int
    let value: String
    let label: String
}

extension BHK {
    static let oneBHK   = BHK(id: 1, value: "ONE_BHK",   label: "1BHK")
    static let twoBHK   = BHK(id: 2, value: "TWO_BHK",   label: "2BHK")
    static let threeBHK = BHK(id: 3, value: "THREE_BHK", label: "3BHK")
    static let studio   = BHK(id: 4, value: "STUDIO",    label: "Studio")

    static let all: [BHK] = [.oneBHK, .twoBHK, .threeBHK, .studio]

    static func find(by id: Int) -> BHK? {
        all.first { $0.id == id }
    }
}
