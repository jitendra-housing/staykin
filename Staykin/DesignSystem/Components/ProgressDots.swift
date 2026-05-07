import SwiftUI

struct ProgressDots: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i == current ? Color.primaryPurple : Color.textDisabled)
                    .frame(width: i == current ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: current)
            }
        }
    }
}
