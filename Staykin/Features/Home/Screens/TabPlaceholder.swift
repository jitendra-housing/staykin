import SwiftUI

struct TabPlaceholder: View {
    let emoji: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: Spacing.md) {
            Spacer()
            Text(emoji).font(.system(size: 64))
            Text(title)
                .font(.heading1)
                .foregroundStyle(Color.textPrimary)
            Text(subtitle)
                .font(.bodyLg)
                .foregroundStyle(Color.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
    }
}
