import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    var sender: Flatmate? = nil
    var onAvatarTap: (() -> Void)? = nil

    var body: some View {
        switch message.direction {
        case .incoming:
            if let sender { groupIncomingBubble(sender: sender) }
            else          { incomingBubble }
        case .outgoing: outgoingBubble
        case .system:   systemBubble
        case .alert:    alertBubble
        }
    }

    // MARK: - 1:1 incoming

    private var incomingBubble: some View {
        HStack {
            Text(message.text)
                .font(.system(size: 13))
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.bgCard)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 18,
                        bottomLeadingRadius: 4,
                        bottomTrailingRadius: 18,
                        topTrailingRadius: 18
                    )
                )
                .frame(maxWidth: 280, alignment: .leading)
            Spacer(minLength: 0)
        }
    }

    // MARK: - Group incoming (avatar + sender label)

    private func groupIncomingBubble(sender: Flatmate) -> some View {
        HStack(alignment: .bottom, spacing: 6) {
            Button {
                onAvatarTap?()
            } label: {
                Avatar(flatmate: sender, size: 26)
            }
            .buttonStyle(.plain)
            .disabled(onAvatarTap == nil)

            VStack(alignment: .leading, spacing: 4) {
                Text(sender.name)
                    .font(.caption1)
                    .foregroundStyle(Color.textSecondary)
                Text(message.text)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.bgCard)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 16,
                            bottomLeadingRadius: 4,
                            bottomTrailingRadius: 16,
                            topTrailingRadius: 16
                        )
                    )
                    .frame(maxWidth: 240, alignment: .leading)
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Outgoing

    private var outgoingBubble: some View {
        HStack {
            Spacer(minLength: 0)
            Text(message.text)
                .font(.system(size: 13))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(LinearGradient.brand)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 18,
                        bottomLeadingRadius: 18,
                        bottomTrailingRadius: 4,
                        topTrailingRadius: 18
                    )
                )
                .frame(maxWidth: 280, alignment: .trailing)
        }
    }

    // MARK: - System (gradient pill)

    private var systemBubble: some View {
        HStack {
            Spacer()
            Text(message.text)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(LinearGradient.brand)
                .clipShape(Capsule())
            Spacer()
        }
    }

    // MARK: - Alert (amber chip)

    private var alertBubble: some View {
        HStack {
            Spacer()
            Text(message.text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: "FCD34D"))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.accentAmber.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.accentAmber.opacity(0.25), lineWidth: 1)
                )
            Spacer()
        }
    }
}
