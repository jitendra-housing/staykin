import SwiftUI

struct FlatmateAvatar: View {
    let flatmate: Flatmate
    var size: CGFloat = 48

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hue: flatmate.avatarHue / 360,  saturation: 0.65, brightness: 0.62),
                    Color(hue: flatmate.avatarHue2 / 360, saturation: 0.65, brightness: 0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if let emoji = flatmate.emoji {
                Text(emoji)
                    .font(.system(size: size * 0.45))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
