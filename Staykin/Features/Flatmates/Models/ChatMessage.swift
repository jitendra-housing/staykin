import Foundation

enum ChatMessageDirection: String, Hashable {
    case incoming = "INCOMING"
    case outgoing = "OUTGOING"
    case system   = "SYSTEM"     // centered gradient pill, e.g. "🎉 You're now flatmates!"
    case alert    = "ALERT"      // centered amber chip, e.g. "⚠️ Still looking for 1 more"
}

struct ChatMessage: Identifiable, Hashable {
    let id: Int
    let threadId: Int
    let senderFlatmateId: Int?   // nil for outgoing (current user) and system messages
    let direction: ChatMessageDirection
    let text: String
    let timestamp: Date
}
