import SwiftUI

struct RequestProfileScreen: View {
    let flatmate: Flatmate
    var showActions: Bool = true
    let onAccept: () -> Void
    let onDecline: () -> Void
    let onBack: () -> Void

    private var firstName: String {
        flatmate.name.split(separator: " ").first.map(String.init) ?? flatmate.name
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 0) {
                    FlatmateVibeCard(flatmate: flatmate)
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if showActions {
                bottomActionBar
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.bgCard)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Color.cardBorder, lineWidth: 1))
            }

            Text("\(firstName)'s vibe")
                .font(.heading2)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            matchBadge
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var matchBadge: some View {
        Text("\(flatmate.matchPct)% ⚡")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Color.accentAmber)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.accentAmber.opacity(0.18))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(Color.accentAmber.opacity(0.4), lineWidth: 1))
    }

    private var bottomActionBar: some View {
        HStack(spacing: 10) {
            Button(action: onDecline) {
                Text("✕ Not my vibe")
                    .font(.buttonLg)
                    .foregroundStyle(Color.destructive)
                    .frame(maxWidth: .infinity)
                    .frame(height: ComponentSize.buttonHeight)
                    .background(Color.destructive.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.full))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.full)
                            .strokeBorder(Color.destructive.opacity(0.4), lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)

            Button(action: onAccept) {
                Text("✨ Accept")
                    .font(.buttonLg)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: ComponentSize.buttonHeight)
                    .background(LinearGradient.brand)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.full))
                    .shadow(color: Color.primaryPurple.opacity(0.38), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, Spacing.xl)
        .background(Color.bgBase)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.cardBorder).frame(height: 1)
        }
    }
}
