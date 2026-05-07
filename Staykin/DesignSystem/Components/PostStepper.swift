import SwiftUI

struct PostStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let unitLabel: String

    var body: some View {
        HStack(spacing: 12) {
            Button {
                value = max(range.lowerBound, value - 1)
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.textSecondary)
                    .frame(width: 30, height: 30)
                    .background(Color.bgCard2)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Color.cardBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)

            HStack(spacing: 4) {
                Text("\(value)")
                    .font(.custom("Outfit", size: 16).weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                Text(unitLabel)
                    .font(.caption1)
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity)

            Button {
                value = min(range.upperBound, value + 1)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(LinearGradient.brand)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .strokeBorder(Color.cardBorder, lineWidth: 1)
        )
    }
}
