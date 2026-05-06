import SwiftUI

struct StaykinTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.textDisabled))
            .font(.bodyLg)
            .foregroundStyle(Color.textPrimary)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled()
            .focused($isFocused)
            .padding(.horizontal, Spacing.md)
            .frame(height: ComponentSize.inputHeight)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .strokeBorder(
                        isFocused ? Color.primaryPurple.opacity(0.6) : Color.cardBorder,
                        lineWidth: 1
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}
