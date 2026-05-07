import SwiftUI

struct SegmentedTabBar<T: Hashable>: View {
    @Binding var selection: T
    let segments: [(value: T, label: String)]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(segments, id: \.value) { seg in
                Button {
                    selection = seg.value
                } label: {
                    Text(seg.label)
                        .font(.caption1.weight(.semibold))
                        .foregroundStyle(selection == seg.value ? Color.white : Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(
                            ZStack {
                                if selection == seg.value {
                                    LinearGradient.brand
                                }
                            }
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.bgCard)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Color.cardBorder, lineWidth: 1))
        .animation(.easeInOut(duration: 0.18), value: selection)
    }
}
