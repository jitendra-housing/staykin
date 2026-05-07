import SwiftUI

struct ConfettiView: View {
    let pieceCount: Int

    private struct Piece: Identifiable {
        let id = UUID()
        let xPercent: Double
        let yPercent: Double
        let color: Color
        let size: Double
        let baseRotation: Double
        let delay: Double
    }

    private let pieces: [Piece]
    private let startDate = Date()
    private let duration: Double = 2.5

    init(pieceCount: Int = 50) {
        self.pieceCount = pieceCount
        let palette: [Color] = [
            Color(hex: "8B5CF6"),
            Color(hex: "A78BFA"),
            Color(hex: "D4A574"),
            .white,
            Color(hex: "10B981")
        ]
        self.pieces = (0..<pieceCount).map { i in
            Piece(
                xPercent: Double.random(in: 0...100),
                yPercent: Double.random(in: 0...100),
                color: palette[i % palette.count],
                size: 4 + Double.random(in: 0...8),
                baseRotation: Double.random(in: 0...360),
                delay: Double.random(in: 0...0.6)
            )
        }
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startDate)
            GeometryReader { geo in
                ZStack {
                    ForEach(pieces) { p in
                        let pieceTime = elapsed - p.delay
                        let t = pieceTime > 0
                            ? pieceTime.truncatingRemainder(dividingBy: duration) / duration
                            : 0
                        let yOffset = -20 + t * 140
                        let rotation = p.baseRotation + t * 720
                        let opacity = pieceTime > 0 ? max(0, 1 - t) : 0

                        Rectangle()
                            .fill(p.color)
                            .frame(width: p.size, height: p.size * 1.4)
                            .rotationEffect(.degrees(rotation))
                            .opacity(opacity)
                            .position(
                                x: geo.size.width * (p.xPercent / 100),
                                y: geo.size.height * (p.yPercent / 100) + yOffset
                            )
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}
