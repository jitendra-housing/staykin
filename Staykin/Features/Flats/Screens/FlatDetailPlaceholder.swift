import SwiftUI

// Phase C will replace this with the real Flat Detail (Screen 26).
struct FlatDetailPlaceholder: View {
    let flat: Flat

    var body: some View {
        VStack(spacing: Spacing.md) {
            Spacer()
            Text(flat.photoEmoji).font(.system(size: 64))
            Text(flat.type.label)
                .font(.heading1)
                .foregroundStyle(Color.textPrimary)
            Text(flat.locality)
                .font(.bodyLg)
                .foregroundStyle(Color.textSecondary)
            Text("Phase C will build the full detail screen")
                .font(.bodySm)
                .foregroundStyle(Color.textDisabled)
                .padding(.top, Spacing.xs)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
    }
}
