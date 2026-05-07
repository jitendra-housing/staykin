import SwiftUI

// Wraps a FlatmateVibeCard with a Tinder-style horizontal swipe gesture.
// The parent owns the deck — this view just reports left/right intent
// after the card animates off-screen.
struct SwipeableFlatmateCard: View {
    let flatmate: Flatmate
    var isInteractive: Bool = true
    let onSwiped: (SwipeDecision) -> Void

    enum SwipeDecision { case skipped, requestSent }

    @State private var dragOffset: CGSize = .zero

    private let threshold: CGFloat = 110

    private var swipeRatio: Double {
        Double(dragOffset.width / threshold).clamped(to: -1...1)
    }

    var body: some View {
        FlatmateVibeCard(flatmate: flatmate)
            .overlay(alignment: .topLeading) {
                if swipeRatio > 0 {
                    sticker(text: "REQUEST SENT", color: .success, rotation: -12)
                        .padding(20)
                        .opacity(min(1, swipeRatio * 1.4))
                }
            }
            .overlay(alignment: .topTrailing) {
                if swipeRatio < 0 {
                    sticker(text: "SKIPPED", color: .destructive, rotation: 12)
                        .padding(20)
                        .opacity(min(1, -swipeRatio * 1.4))
                }
            }
            .offset(dragOffset)
            .rotationEffect(.degrees(swipeRatio * 8), anchor: .bottom)
            .gesture(isInteractive ? swipeGesture : nil)
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                if value.translation.width > threshold {
                    flyOff(decision: .requestSent, toward: 600)
                } else if value.translation.width < -threshold {
                    flyOff(decision: .skipped, toward: -600)
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    private func flyOff(decision: SwipeDecision, toward x: CGFloat) {
        withAnimation(.easeOut(duration: 0.28)) {
            dragOffset = CGSize(width: x, height: dragOffset.height)
        }
        Task {
            try? await Task.sleep(for: .milliseconds(280))
            onSwiped(decision)
        }
    }

    private func sticker(text: String, color: Color, rotation: Double) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .heavy))
            .tracking(1)
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(color, lineWidth: 3)
            )
            .rotationEffect(.degrees(rotation))
    }
}

