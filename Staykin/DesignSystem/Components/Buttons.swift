import SwiftUI

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.buttonLg)
                .foregroundStyle(isDisabled ? Color.textDisabled : .white)
                .frame(maxWidth: .infinity)
                .frame(height: ComponentSize.buttonHeight)
                .background(
                    Group {
                        if isDisabled {
                            Color.bgCard
                        } else {
                            LinearGradient.brand
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: Radius.full))
                .shadow(color: .primaryPurple.opacity(isDisabled ? 0 : 0.38), radius: 12, x: 0, y: 4)
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .opacity(isPressed ? 0.9 : 1.0)
        }
        .disabled(isDisabled)
        .buttonStyle(ScaleButtonStyle(isPressed: $isPressed))
    }
}

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.buttonLg)
                .gradientForeground(.brand)
                .frame(maxWidth: .infinity)
                .frame(height: ComponentSize.buttonHeight)
                .background(Color.primaryPurple.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: Radius.full))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.full)
                        .strokeBorder(
                            LinearGradient.brand,
                            lineWidth: 1.5
                        )
                )
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .opacity(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(ScaleButtonStyle(isPressed: $isPressed))
    }
}

// MARK: - Scale Button Style (internal press tracking)

private struct ScaleButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, pressed in
                withAnimation(.easeInOut(duration: 0.12)) {
                    isPressed = pressed
                }
            }
    }
}
