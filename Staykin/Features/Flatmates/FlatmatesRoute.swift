import Foundation

enum FlatmatesRoute: Hashable {
    case requestProfile(flatmateId: Int)
    case directChat(threadId: Int)
    case groupChat(threadId: Int)
}
