import SwiftUI

struct OTPScreen: View {
    let onVerify: () async -> Void
    let onBack: () -> Void

    @Environment(OnboardingData.self) private var data
    @FocusState private var otpFocused: Bool
    @State private var resendSeconds: Int = 23
    @State private var showError = false
    @State private var isVerifying = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        @Bindable var data = data

        VStack(alignment: .leading, spacing: 0) {
            // Header: back + Staykin
            HStack(spacing: 10) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.bgCard)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(Color.cardBorder, lineWidth: 1))
                }
                Text("Staykin")
                    .font(.custom("Outfit", size: 22).weight(.heavy))
                    .gradientForeground(.brand)
            }
            .padding(.top, Spacing.xs)

            Text("Enter the code")
                .font(.display)
                .foregroundStyle(Color.textPrimary)
                .padding(.top, 32)

            HStack(spacing: 6) {
                Text("Sent to \(data.countryCode) \(formattedPhone(data.phoneNumber))")
                    .font(.bodySm)
                    .foregroundStyle(Color.textSecondary)
                Button(action: onBack) {
                    Text("edit")
                        .font(.bodySm.weight(.semibold))
                        .foregroundStyle(Color.primaryPurple)
                        .underline()
                }
            }
            .padding(.top, Spacing.xs)

            // OTP boxes with hidden TextField behind
            ZStack {
                TextField("", text: Binding(
                    get: { data.otpCode },
                    set: { newValue in
                        let digits = newValue.filter(\.isNumber).prefix(6)
                        data.otpCode = String(digits)
                        if showError && digits.count < 6 {
                            withAnimation { showError = false }
                        }
                    }
                ))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($otpFocused)
                .opacity(0)
                .frame(height: 56)

                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { i in
                        OTPBox(
                            char: charAt(i, in: data.otpCode),
                            isFilled: i < data.otpCode.count,
                            isCursor: !showError && i == data.otpCode.count && otpFocused,
                            isError: showError
                        )
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { otpFocused = true }
            .padding(.top, 28)

            if showError {
                HStack(spacing: 8) {
                    Text("⚠️").font(.system(size: 16))
                    Text("Wrong code, bestie. Try again 🔄")
                        .font(.bodySm.weight(.medium))
                        .foregroundStyle(Color.destructive)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.destructive.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.destructive.opacity(0.3), lineWidth: 1)
                )
                .padding(.top, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            HStack {
                Text("Didn't get it?")
                    .font(.caption1)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                if resendSeconds > 0 && !showError {
                    Text("Resend in 0:\(String(format: "%02d", resendSeconds))")
                        .font(.caption1.weight(.semibold))
                        .foregroundStyle(Color.textDisabled)
                } else {
                    Button(action: handleResend) {
                        Text("Resend code")
                            .font(.caption1.weight(.semibold))
                            .foregroundStyle(showError ? Color.accentAmber : Color.primaryPurple)
                    }
                }
            }
            .padding(.top, 18)

            PrimaryButton(
                title: showError ? "Try again" : "Verify ✨",
                action: handleVerify,
                isDisabled: data.otpCode.count != 6,
                isLoading: isVerifying
            )
            .padding(.top, Spacing.xl)

            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
        .onAppear { otpFocused = true }
        .onReceive(timer) { _ in
            if resendSeconds > 0 { resendSeconds -= 1 }
        }
    }

    private func handleVerify() {
        // Only "111111" is accepted; any other code triggers the error state for QA.
        guard data.otpCode == "111111" else {
            withAnimation { showError = true }
            return
        }
        guard !isVerifying else { return }
        isVerifying = true
        Task { @MainActor in
            await onVerify()
            isVerifying = false
        }
    }

    private func handleResend() {
        data.otpCode = ""
        withAnimation { showError = false }
        resendSeconds = 23
    }

    private func charAt(_ i: Int, in s: String) -> String {
        guard i < s.count else { return "" }
        return String(s[s.index(s.startIndex, offsetBy: i)])
    }

    private func formattedPhone(_ digits: String) -> String {
        let chars = Array(digits)
        guard chars.count > 5 else { return String(chars) }
        return "\(String(chars.prefix(5))) \(String(chars.dropFirst(5)))"
    }
}

private struct OTPBox: View {
    let char: String
    let isFilled: Bool
    let isCursor: Bool
    let isError: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isError ? Color.destructive.opacity(0.08) : Color.bgCard)
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(borderColor, lineWidth: 1.5)

            if isFilled {
                Text(char)
                    .font(.custom("Outfit", size: 22).weight(.bold))
                    .foregroundStyle(isError ? Color.destructive : Color.textPrimary)
            } else if isCursor {
                BlinkingCursor()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
    }

    private var borderColor: Color {
        if isError { return .destructive }
        if isFilled || isCursor { return .primaryPurple }
        return .cardBorder
    }
}

private struct BlinkingCursor: View {
    @State private var on = true

    var body: some View {
        Rectangle()
            .fill(Color.primaryPurple)
            .frame(width: 2, height: 24)
            .opacity(on ? 1 : 0)
            .onAppear {
                withAnimation(.linear(duration: 0.5).repeatForever()) {
                    on.toggle()
                }
            }
    }
}
