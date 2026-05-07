import SwiftUI

struct Avatar: View {
    let size: CGFloat
    let hue: Double
    var hue2: Double? = nil
    var initial: String? = nil
    var emoji: String? = nil

    var body: some View {
        let endHue = (hue2 ?? hue + 50).truncatingRemainder(dividingBy: 360)

        ZStack {
            LinearGradient(
                colors: [
                    Color(hue: hue / 360, saturation: 0.55, brightness: 0.78),
                    Color(hue: endHue / 360, saturation: 0.55, brightness: 0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if let emoji {
                Text(emoji)
                    .font(.system(size: size * 0.42))
            } else if let initial {
                Text(initial)
                    .font(.custom("Outfit", size: size * 0.42).weight(.bold))
                    .foregroundStyle(.white)
            }

            RadialGradient(
                colors: [Color.white.opacity(0.3), .clear],
                center: UnitPoint(x: 0.3, y: 0.3),
                startRadius: 0,
                endRadius: size * 0.5
            )
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

extension Avatar {
    init(flatmate: Flatmate, size: CGFloat, useEmoji: Bool = false) {
        let initial: String? = useEmoji ? nil : flatmate.name.first.map { String($0) }
        self.init(
            size: size,
            hue: flatmate.avatarHue,
            hue2: flatmate.avatarHue2,
            initial: initial,
            emoji: useEmoji ? flatmate.emoji : nil
        )
    }
}
