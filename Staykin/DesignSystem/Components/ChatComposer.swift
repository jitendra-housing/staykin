import SwiftUI

struct ChatComposer: View {
    @Binding var text: String
    let placeholder: String
    let onSend: () -> Void

    @FocusState private var focused: Bool

    private var hasContent: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: 10) {
            TextField(
                "",
                text: $text,
                prompt: Text(placeholder).foregroundStyle(Color.textSecondary),
                axis: .vertical
            )
            .font(.system(size: 13))
            .foregroundStyle(Color.textPrimary)
            .lineLimit(1...4)
            .focused($focused)
            .padding(.horizontal, 16)
            .frame(minHeight: 42)
            .background(Color.bgCard)
            .clipShape(Capsule())

            Button(action: onSend) {
                Text("➤")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(LinearGradient.brand)
                    .clipShape(Circle())
                    .opacity(hasContent ? 1 : 0.6)
            }
            .buttonStyle(.plain)
            .disabled(!hasContent)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, Spacing.xl)
        .background(Color.bgSheet)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.cardBorder).frame(height: 1)
        }
    }
}
