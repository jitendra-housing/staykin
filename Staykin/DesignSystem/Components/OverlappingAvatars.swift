import SwiftUI

struct OverlappingAvatars: View {
    struct Spec: Hashable {
        let hue: Double
        let hue2: Double
        var initial: String? = nil
        var emoji: String? = nil
    }

    let specs: [Spec]
    var size: CGFloat = 32
    var overlap: CGFloat = 10

    var body: some View {
        HStack(spacing: -overlap) {
            ForEach(Array(specs.enumerated()), id: \.offset) { _, spec in
                Avatar(
                    size: size,
                    hue: spec.hue,
                    hue2: spec.hue2,
                    initial: spec.initial,
                    emoji: spec.emoji
                )
                .overlay(Circle().strokeBorder(Color.bgSheet, lineWidth: 2))
            }
        }
    }
}

extension OverlappingAvatars.Spec {
    init(flatmate: Flatmate) {
        self.init(
            hue: flatmate.avatarHue,
            hue2: flatmate.avatarHue2,
            initial: flatmate.name.first.map { String($0) },
            emoji: nil
        )
    }
}
