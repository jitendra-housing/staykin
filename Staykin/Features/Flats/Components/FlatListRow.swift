import SwiftUI

struct FlatListRow: View {
    let flat: Flat

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            PhotoPlaceholder(
                hue: flat.photoHue,
                hue2: flat.photoHue2,
                emoji: flat.photoEmoji
            )
            .frame(width: 84, height: 84)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 0) {
                // Type heading + rent
                HStack(alignment: .firstTextBaseline) {
                    Text(flat.type.label)
                        .font(.custom("Outfit", size: 14).weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    Spacer(minLength: 6)

                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(flat.rentLabel)
                            .font(.custom("Outfit", size: 14).weight(.bold))
                            .foregroundStyle(Color.textPrimary)
                        Text("/mo")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                // Locality with map-pin
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.textSecondary)
                    Text(flat.locality)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                }
                .padding(.top, 3)

                // Amenities · joined
                Text(flat.amenities.map(\.label).joined(separator: " · "))
                    .font(.system(size: 11))
                    .foregroundStyle(Color.textDisabled)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.top, 4)

                if let residents = flat.totalResidents {
                    Spacer(minLength: 4)

                    Text("👥 \(residents) resident\(residents == 1 ? "" : "s")")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
        }
        .contentShape(Rectangle())
    }
}
