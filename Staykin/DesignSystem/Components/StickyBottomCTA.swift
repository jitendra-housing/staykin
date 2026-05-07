import SwiftUI

struct StickyBottomCTA: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.bgBase.opacity(0), Color.bgBase],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 24)

            PrimaryButton(title: title, action: action, isDisabled: isDisabled, isLoading: isLoading)
                .padding(.horizontal, Spacing.screenHPad)
                .padding(.bottom, Spacing.xl)
                .background(Color.bgBase)
        }
    }
}
