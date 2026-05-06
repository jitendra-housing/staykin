import SwiftUI

struct PhoneScreen: View {
    let onContinue: () -> Void

    @Environment(OnboardingData.self) private var data
    @FocusState private var phoneFocused: Bool

    private var canContinue: Bool { data.phoneNumber.count == 10 }

    var body: some View {
        @Bindable var data = data

        VStack(alignment: .leading, spacing: 0) {
            Text("Staykin")
                .font(.custom("Outfit", size: 28).weight(.heavy))
                .gradientForeground(.brand)
                .padding(.top, 20)

            Text("What's your number?")
                .font(.display)
                .foregroundStyle(Color.textPrimary)
                .padding(.top, 40)

            Text("We'll send you a code. No spam, promise 🤙")
                .font(.bodySm)
                .foregroundStyle(Color.textSecondary)
                .padding(.top, Spacing.xs)

            HStack(spacing: Spacing.xs) {
                // Country code chip
                HStack(spacing: 6) {
                    Text("🇮🇳").font(.system(size: 20))
                    Text(data.countryCode)
                        .font(.bodyLg)
                        .foregroundStyle(Color.textPrimary)
                }
                .padding(.horizontal, 14)
                .frame(width: 88, height: ComponentSize.inputHeight, alignment: .leading)
                .background(Color.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .strokeBorder(Color.cardBorder, lineWidth: 1)
                )

                // Phone field with format-on-type
                TextField(
                    "",
                    text: Binding(
                        get: { formatted(data.phoneNumber) },
                        set: { newValue in
                            let digits = newValue.filter(\.isNumber).prefix(10)
                            data.phoneNumber = String(digits)
                        }
                    ),
                    prompt: Text("98765 43210").foregroundStyle(Color.textDisabled)
                )
                .font(.bodyLg)
                .foregroundStyle(Color.textPrimary)
                .keyboardType(.numberPad)
                .textContentType(.telephoneNumber)
                .focused($phoneFocused)
                .padding(.horizontal, Spacing.md)
                .frame(maxWidth: .infinity)
                .frame(height: ComponentSize.inputHeight)
                .background(Color.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .strokeBorder(
                            phoneFocused ? Color.primaryPurple : Color.cardBorder,
                            lineWidth: phoneFocused ? 1.5 : 1
                        )
                )
                .animation(.easeInOut(duration: 0.15), value: phoneFocused)
            }
            .padding(.top, 32)

            PrimaryButton(title: "Next →", action: onContinue, isDisabled: !canContinue)
                .padding(.top, 28)

            Text("By continuing, you agree to our Terms · Privacy")
                .font(.caption1)
                .foregroundStyle(Color.textDisabled)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, Spacing.md)

            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
        .onAppear { phoneFocused = true }
    }

    private func formatted(_ digits: String) -> String {
        let chars = Array(digits)
        if chars.count <= 5 { return String(chars) }
        return "\(String(chars.prefix(5))) \(String(chars.dropFirst(5)))"
    }
}
