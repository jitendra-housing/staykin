import SwiftUI

struct PostStepHeader: View {
    let stepIndex: Int
    let totalSteps: Int
    let title: String
    var subtitle: String? = nil
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(Color.bgCard)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(Color.cardBorder, lineWidth: 1))
                }
                Spacer()
                ProgressDots(current: stepIndex, total: totalSteps)
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }

            StepPill(text: "📝 Post your Space")
                .padding(.top, 16)

            Text(title)
                .font(.heading1)
                .foregroundStyle(Color.textPrimary)
                .padding(.top, 8)

            if let subtitle {
                Text(subtitle)
                    .font(.bodySm)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.top, 6)
            }
        }
    }
}
