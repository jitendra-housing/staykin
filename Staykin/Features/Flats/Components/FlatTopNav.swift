import SwiftUI

struct FlatTopNav: View {
    let onBack: () -> Void
    var onShare: (() -> Void)? = nil

    var body: some View {
        HStack {
            navButton(icon: "chevron.left", action: onBack)
            Spacer()
            navButton(icon: "square.and.arrow.up", action: { onShare?() })
        }
    }

    private func navButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.black.opacity(0.45))
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
