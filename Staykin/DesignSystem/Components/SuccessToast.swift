import SwiftUI

// Floating success toast with optional inline link.
// Designed to be overlaid at the bottom of a screen.
struct SuccessToast: View {
    let title: String
    var subtitle: String? = nil
    var actionLabel: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.22))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)

                if subtitle != nil || actionLabel != nil {
                    subtitleRow
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background {
            ZStack {
                Color.success.opacity(0.92)
                Rectangle().fill(.ultraThinMaterial).blendMode(.overlay)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.success.opacity(0.45), radius: 18, x: 0, y: 6)
    }

    @ViewBuilder
    private var subtitleRow: some View {
        HStack(spacing: 4) {
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.9))
            }
            if let actionLabel, let onAction {
                Button(action: onAction) {
                    Text(actionLabel)
                        .font(.system(size: 12, weight: .semibold))
                        .underline()
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
