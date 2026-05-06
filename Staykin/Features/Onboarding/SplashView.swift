import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void

    @State private var opacity: Double = 0
    @State private var wordmarkScale: Double = 0.9

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()

            // Bottom ambient glow
            Circle()
                .fill(LinearGradient.brand)
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .opacity(0.12)
                .offset(y: 280)

            VStack(spacing: Spacing.xs) {
                Text("staykin")
                    .font(.display)
                    .gradientForeground()
                    .scaleEffect(wordmarkScale)

                Text("Find your tribe, not just a room")
                    .font(.bodyLg)
                    .foregroundStyle(Color.textSecondary)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                opacity = 1
                wordmarkScale = 1
            }
            // Auto-advance after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onFinish()
            }
        }
    }
}

#Preview {
    SplashView(onFinish: {})
}
