import SwiftUI

struct TabBar: View {
    @Binding var selected: HomeTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeTab.allCases, id: \.self) { tab in
                Button {
                    selected = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(
                                selected == tab
                                    ? AnyShapeStyle(LinearGradient.brand)
                                    : AnyShapeStyle(Color.textSecondary.opacity(0.6))
                            )
                        Text(tab.label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(
                                selected == tab
                                    ? Color.textPrimary
                                    : Color.textSecondary.opacity(0.6)
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background {
            ZStack {
                Color.bgBase.opacity(0.85)
                Rectangle().fill(.ultraThinMaterial)
            }
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
        }
    }
}
