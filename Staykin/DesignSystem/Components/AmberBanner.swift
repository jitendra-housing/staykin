import SwiftUI

struct AmberBanner: View {
    let text: String
    var trailingText: String? = nil
    var onTrailingTap: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: "FCD34D"))

            Spacer()

            if let trailingText {
                Button {
                    onTrailingTap?()
                } label: {
                    Text(trailingText)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.accentAmber)
                }
                .buttonStyle(.plain)
                .disabled(onTrailingTap == nil)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.accentAmber.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(alignment: .leading) {
            Rectangle().fill(Color.accentAmber).frame(width: 3)
        }
    }
}
