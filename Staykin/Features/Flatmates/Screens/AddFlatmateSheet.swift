import SwiftUI

struct AddFlatmateSheet: View {
    let flatmate: Flatmate
    let slotsFilled: Int            // current squad size (incl. you), before this addition
    let slotsNeeded: Int            // target squad size
    let onConfirm: () -> Void
    let onCancel: () -> Void

    private var firstName: String {
        flatmate.name.split(separator: " ").first.map(String.init) ?? flatmate.name
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    pairedAvatars
                        .padding(.top, 24)
                        .padding(.bottom, 16)

                    Text("Make \(firstName) your flatmate?")
                        .font(.heading1)
                        .foregroundStyle(Color.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Text("You'll both be marked as flatmates.\nA group forms when you add more 💅")
                        .font(.bodySm)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.top, 8)
                        .padding(.horizontal, 24)

                    SlotProgressDots(filled: slotsFilled, total: slotsNeeded)
                        .padding(.top, 24)

                    Text("\(min(slotsFilled + 1, slotsNeeded)) of \(slotsNeeded)")
                        .font(.bodySm.weight(.medium))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)
            }

            VStack(spacing: 10) {
                PrimaryButton(title: "Yes, we vibe! ✨", action: onConfirm)

                Button(action: onCancel) {
                    Text("Not yet")
                        .font(.bodyLg)
                        .foregroundStyle(Color.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 14)
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity)
            .background(Color.bgSheet)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgSheet)
    }

    // MARK: - Paired avatars

    private var pairedAvatars: some View {
        ZStack {
            bigAvatar(emoji: "🦄", hue: 280, hue2: 320)
                .offset(x: -32)

            bigAvatar(
                emoji: flatmate.emoji ?? "✨",
                hue: flatmate.avatarHue,
                hue2: flatmate.avatarHue2
            )
            .offset(x: 32)
        }
        .frame(height: 90)
        .frame(maxWidth: .infinity)
    }

    private func bigAvatar(emoji: String, hue: Double, hue2: Double) -> some View {
        Avatar(size: 80, hue: hue, hue2: hue2, emoji: emoji)
            .overlay(Circle().strokeBorder(LinearGradient.brand, lineWidth: 3))
            .padding(2)
            .background(Circle().fill(Color.bgSheet))
    }
}
