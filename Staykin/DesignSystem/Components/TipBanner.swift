import SwiftUI

enum TipBannerVariant {
    case amber
    case purple
}

struct TipBanner: View {
    let variant: TipBannerVariant
    let emoji: String
    let leadText: String
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(emoji).font(.system(size: 22))

            (Text(leadText).font(.caption1.weight(.bold))
             + Text(" " + text).font(.caption1))
                .foregroundStyle(textColor)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .strokeBorder(borderColor, lineWidth: 1)
        )
    }

    private var textColor: Color {
        switch variant {
        case .amber:  return Color(hex: "FCD34D")
        case .purple: return Color(hex: "C4B5FD")
        }
    }

    private var bgColor: Color {
        switch variant {
        case .amber:  return Color.accentAmber.opacity(0.10)
        case .purple: return Color.primaryPurple.opacity(0.08)
        }
    }

    private var borderColor: Color {
        switch variant {
        case .amber:  return Color.accentAmber.opacity(0.22)
        case .purple: return Color.primaryPurple.opacity(0.18)
        }
    }
}
