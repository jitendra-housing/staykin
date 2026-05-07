import Foundation

enum FlatmatesRoute: Hashable {
    case requestProfile(flatmateId: Int, showActions: Bool)
    case directChat(threadId: Int)
    case groupChat(threadId: Int)
}
