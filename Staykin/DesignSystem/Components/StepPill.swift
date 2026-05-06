import SwiftUI

struct StepPill: View {
    let text: String
    var isAmber: Bool = false   // amber = step 2/2, purple = step 1/2

    var body: some View {
        Text(text)
            .font(.caption1)
            .foregroundStyle(isAmber ? Color.accentAmber : Color(hex: "C4B5FD"))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(
                    isAmber
                        ? Color.accentAmber.opacity(0.14)
                        : Color.primaryPurple.opacity(0.08)
                )
            )
            .overlay(
                Capsule().strokeBorder(
                    isAmber
                        ? Color.accentAmber.opacity(0.25)
                        : Color.primaryPurple.opacity(0.18),
                    lineWidth: 1
                )
            )
    }
}
