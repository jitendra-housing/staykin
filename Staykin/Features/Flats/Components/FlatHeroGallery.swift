import SwiftUI

struct FlatHeroGallery: View {
    let photos: [FlatPhoto]
    @State private var index: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $index) {
                ForEach(photos.indices, id: \.self) { i in
                    let photo = photos[i]
                    ZStack {
                        PhotoPlaceholder(
                            hue: photo.placeholderHue,
                            hue2: photo.placeholderHue2,
                            emoji: photo.placeholderEmoji
                        )
                        if let urlString = photo.url, let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

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
                            .animation(.easeInOut(duration: 0.2), value: index)
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
