import SwiftUI

struct FlatmateProfileSheet: View {
    let flatmate: Flatmate
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(spacing: 0) {
                    FlatmateVibeCard(flatmate: flatmate)
                        .padding(.horizontal, 18)
                        .padding(.top, 12)

                    closeButtonLarge
                        .padding(.top, 24)
                        .padding(.bottom, 22)
                }
            }
            .background(Color.bgSheet)

            closeButtonSmall
                .padding(.top, 12)
                .padding(.trailing, 16)
        }
    }

    // 28pt close in top-right of the sheet header
    private var closeButtonSmall: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 28, height: 28)
                .background(Color.bgCard)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.cardBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // 56pt close beneath the card
    private var closeButtonLarge: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.textPrimary)
                .frame(width: 56, height: 56)
                .background(Color.bgCard)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.cardBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
