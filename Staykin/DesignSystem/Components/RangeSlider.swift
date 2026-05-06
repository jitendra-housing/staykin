import SwiftUI

struct RangeSlider: View {
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    let range: ClosedRange<Double>
    var step: Double = 1

    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 24
    private let coordinateSpaceName = "RangeSlider"

    var body: some View {
        GeometryReader { geo in
            let usableWidth = geo.size.width - thumbSize
            let lowerX = thumbSize / 2 + CGFloat((lowerValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * usableWidth
            let upperX = thumbSize / 2 + CGFloat((upperValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * usableWidth

            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: trackHeight)

                // Active track
                Capsule()
                    .fill(LinearGradient.brand)
                    .frame(width: upperX - lowerX, height: trackHeight)
                    .offset(x: lowerX)

                // Lower thumb
                thumb(value: $lowerValue, x: lowerX, usableWidth: usableWidth, isLower: true)

                // Upper thumb
                thumb(value: $upperValue, x: upperX, usableWidth: usableWidth, isLower: false)
            }
            .frame(height: thumbSize)
            .coordinateSpace(name: coordinateSpaceName)
        }
        .frame(height: thumbSize)
    }

    @ViewBuilder
    private func thumb(value: Binding<Double>, x: CGFloat, usableWidth: CGFloat, isLower: Bool) -> some View {
        Circle()
            .fill(Color.white)
            .frame(width: thumbSize, height: thumbSize)
            .shadow(color: .primaryPurple.opacity(0.4), radius: 6, x: 0, y: 2)
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
