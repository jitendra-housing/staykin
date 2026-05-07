import SwiftUI

struct EmptySlotRow: View {
    let rentShare: Int
    let availableNow: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.primaryPurple.opacity(0.08))
                Circle()
                    .strokeBorder(
                        Color.primaryPurple.opacity(0.4),
                        style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])
                    )
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(Color(hex: "C4B5FD"))
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text("This could be you")
                    .font(.custom("Outfit", size: 13).weight(.bold))
                    .foregroundStyle(Color(hex: "C4B5FD"))

                Text(subtitleText)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    Color.primaryPurple.opacity(0.4),
                    style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])
                )
        )
    }

    private var subtitleText: String {
        let rent = "₹\(rentShare / 1000)K share"
        return "Private room · \(rent)\(availableNow ? " · avail now" : "")"
    }
}
