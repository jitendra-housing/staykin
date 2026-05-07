import SwiftUI

// Stand-in for an image until we have CDN URLs. Mirrors the design's
// PhotoPH (hue/hue2 gradient + emoji) for parity with the spec.
struct PhotoPlaceholder: View {
    let hue: Double          // 0–360
    let hue2: Double         // 0–360
    var emoji: String? = nil

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hue: hue / 360,  saturation: 0.62, brightness: 0.55),
                    Color(hue: hue2 / 360, saturation: 0.62, brightness: 0.70)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            if let emoji {
                Text(emoji)
                    .font(.system(size: 32))
                    .opacity(0.9)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
            }
        }
    }
}
