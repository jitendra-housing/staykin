import SwiftUI

struct RangeSlider: View {
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    let range: ClosedRange<Double>
    var step: Double = 1
    var tooltipFormatter: ((Double) -> String)? = nil

    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 20
    private let coordinateSpaceName = "RangeSlider"

    var body: some View {
        GeometryReader { geo in
            let usableWidth = geo.size.width - thumbSize
            let lowerX = thumbSize / 2 + CGFloat((lowerValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * usableWidth
            let upperX = thumbSize / 2 + CGFloat((upperValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * usableWidth

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.bgCard)
                    .frame(height: trackHeight)

                Capsule()
                    .fill(LinearGradient.brand)
                    .frame(width: max(0, upperX - lowerX), height: trackHeight)
                    .offset(x: lowerX)

                thumb(value: $lowerValue, x: lowerX, usableWidth: usableWidth, isLower: true)
                thumb(value: $upperValue, x: upperX, usableWidth: usableWidth, isLower: false)
            }
            .frame(height: thumbSize)
            .coordinateSpace(name: coordinateSpaceName)
        }
        .frame(height: thumbSize)
    }

    private func thumb(value: Binding<Double>, x: CGFloat, usableWidth: CGFloat, isLower: Bool) -> some View {
        ZStack {
            // 4px halo around the thumb
            Circle()
                .fill(Color.primaryPurple.opacity(0.10))
                .frame(width: thumbSize + 8, height: thumbSize + 8)
            Circle()
                .fill(Color.primaryPurple)
                .frame(width: thumbSize, height: thumbSize)
        }
        .frame(width: thumbSize, height: thumbSize)
        .overlay(alignment: .bottom) {
            if let formatter = tooltipFormatter {
                Text(formatter(value.wrappedValue))
                    .font(.caption1)
                    .foregroundStyle(Color.textPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(Color.cardBorder, lineWidth: 1)
                    )
                    .fixedSize()
                    .offset(y: -32)
            }
        }
        .offset(x: x - thumbSize / 2)
        .gesture(
            DragGesture(coordinateSpace: .named(coordinateSpaceName))
                .onChanged { drag in
                    let ratio = (drag.location.x - thumbSize / 2) / usableWidth
                    let raw = range.lowerBound + Double(ratio.clamped(to: 0...1)) * (range.upperBound - range.lowerBound)
                    let stepped = (raw / step).rounded() * step
                    let clamped = stepped.clamped(to: range)
                    if isLower {
                        value.wrappedValue = min(clamped, upperValue - step)
                    } else {
                        value.wrappedValue = max(clamped, lowerValue + step)
                    }
                }
        )
    }
}

// MARK: - Comparable clamping helpers

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension CGFloat {
    func clamped(to limits: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, limits.lowerBound), limits.upperBound)
    }
}
