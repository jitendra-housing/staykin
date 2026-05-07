import SwiftUI

struct TrustStrip: View {
    let detail: FlatDetail

    var body: some View {
        FlowLayout(spacing: 6) {
            if detail.verified {
                verifiedBadge
            }
            metaItem(detail.bhk.label, accent: false)
            dot
            metaItem(detail.furnishing.label, accent: false)
            dot
            metaItem("\(detail.areaSqft) sqft", accent: false)
            if detail.availableNow {
                dot
                metaItem("⚡ Avail now", accent: true)
            }
        }
    }

    private var verifiedBadge: some View {
        HStack(spacing: 3) {
            Text("✓").font(.system(size: 9, weight: .heavy))
            Text("Verified").font(.system(size: 10, weight: .heavy))
        }
        .foregroundStyle(Color.success)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Color.success.opacity(0.15))
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Color.success.opacity(0.4), lineWidth: 1))
    }

    private var dot: some View {
        Text("·")
            .font(.system(size: 11))
            .foregroundStyle(Color.textSecondary)
    }

    private func metaItem(_ text: String, accent: Bool) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(accent ? Color.accentAmber : Color.textPrimary)
    }
}
