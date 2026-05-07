import Foundation

struct FlatType: Identifiable, Hashable {
    let id: Int
    let value: String
    let label: String
}

extension FlatType {
    static let privateRoom = FlatType(id: 1, value: "PRIVATE_ROOM", label: "Private Room")
    static let sharedRoom  = FlatType(id: 2, value: "SHARED_ROOM",  label: "Shared Room")

    static let all: [FlatType] = [.privateRoom, .sharedRoom]

    static func find(by id: Int) -> FlatType? {
        all.first { $0.id == id }
    }
}
