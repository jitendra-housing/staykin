import SwiftUI

struct FlatmateProfileSheet: View {
    let flatmate: Flatmate
    let onClose: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                FlatmateVibeCard(flatmate: flatmate)
                    .padding(.horizontal, 18)
                    .padding(.top, 4)

                aboutSection

                closeButton
                    .padding(.bottom, 22)
            }
        }
        .background(Color.bgSheet)
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("About")
                .font(.custom("Outfit", size: 14).weight(.semibold))
                .foregroundStyle(Color.textPrimary)
            Text(flatmate.bio)
                .font(.system(size: 12))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.top, 16)
        .padding(.bottom, 18)
    }

    private var closeButton: some View {
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
