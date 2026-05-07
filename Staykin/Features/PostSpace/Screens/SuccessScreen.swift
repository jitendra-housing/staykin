import SwiftUI

struct SuccessScreen: View {
    let onViewListing: () -> Void
    let onBrowseFlatmates: () -> Void

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()

            // Ambient blurred glow
            Circle()
                .fill(LinearGradient.brand)
                .frame(width: 500, height: 500)
                .blur(radius: 80)
                .opacity(0.20)
                .offset(y: -180)

            ConfettiView(pieceCount: 50)

            VStack(spacing: 0) {
                Spacer().frame(height: 140)

                ZStack {
                    Circle()
                        .fill(LinearGradient.brand)
                        .frame(width: 96, height: 96)
                        .shadow(color: Color.primaryPurple.opacity(0.35), radius: 20, x: 0, y: 12)

                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text("Your flat is live! 🚀")
                    .font(.custom("Outfit", size: 36).weight(.bold))
                    .gradientForeground(.brand)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)

                Text("People can start swiping on it now")
                    .font(.bodyLg)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.top, 10)

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.success)
                        .frame(width: 8, height: 8)
                    Text("Active · Boosted for 24h")
                        .font(.caption1.weight(.bold))
                }
                .foregroundStyle(Color.success)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.success.opacity(0.15))
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(Color.success.opacity(0.4), lineWidth: 1))
                .padding(.top, 18)

                Spacer()

                VStack(spacing: 10) {
                    PrimaryButton(title: "View my listing →", action: onViewListing)
                    SecondaryButton(title: "Browse flatmates", action: onBrowseFlatmates)
                }
                .padding(.horizontal, Spacing.xxl)
                .padding(.bottom, 60)
            }
            .padding(.horizontal, Spacing.xxl)
        }
        .navigationBarBackButtonHidden(true)
    }
}
