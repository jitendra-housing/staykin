import SwiftUI

struct FlatHeroGallery: View {
    let photos: [FlatPhoto]
    @State private var index: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Photo (Phase C ships first photo only — horizontal paging deferred)
            if let current = photos[safe: index] {
                PhotoPlaceholder(
                    hue: current.placeholderHue,
                    hue2: current.placeholderHue2,
                    emoji: current.placeholderEmoji
                )
            }

            // Top scrim for nav button readability
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.black.opacity(0.5), .clear],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 100)
                Spacer()
            }
            .allowsHitTesting(false)

            // Bottom paging dots
            if photos.count > 1 {
                HStack(spacing: 4) {
                    ForEach(photos.indices, id: \.self) { i in
                        Capsule()
                            .fill(i == index ? Color.white : Color.white.opacity(0.5))
                            .frame(width: i == index ? 18 : 6, height: 6)
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .clipped()
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
