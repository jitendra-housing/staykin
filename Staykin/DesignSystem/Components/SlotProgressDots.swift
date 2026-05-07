import SwiftUI

struct SlotProgressDots: View {
    let filled: Int
    let total: Int
    var dotSize: CGFloat = 28

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                let isFilled = i < filled
                Circle()
                    .fill(isFilled ? Color.accentAmber.opacity(0.25) : Color.bgCard)
                    .frame(width: dotSize, height: dotSize)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                isFilled ? Color.accentAmber.opacity(0.5) : Color.cardBorder,
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: isFilled ? Color.accentAmber.opacity(0.25) : .clear,
                        radius: 4, x: 0, y: 4
                    )
            }
        }
    }
}
