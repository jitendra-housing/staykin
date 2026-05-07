import Foundation

struct Furnishing: Identifiable, Hashable {
    let id: Int
    let value: String
    let label: String
}

extension Furnishing {
    static let furnished   = Furnishing(id: 1, value: "FURNISHED",   label: "Furnished")
    static let semi        = Furnishing(id: 2, value: "SEMI",        label: "Semi")
    static let unfurnished = Furnishing(id: 3, value: "UNFURNISHED", label: "Unfurnished")

    static let all: [Furnishing] = [.furnished, .semi, .unfurnished]

    static func find(by id: Int) -> Furnishing? {
        all.first { $0.id == id }
    }
}
