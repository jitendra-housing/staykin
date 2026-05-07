import SwiftUI

struct PhotoTile: View {
    enum Content {
        case empty
        case image(UIImage, isCover: Bool)
        case placeholder(emoji: String, gradient: LinearGradient, isCover: Bool)
    }

    let content: Content
    var onAdd: (() -> Void)? = nil
    var onRemove: (() -> Void)? = nil

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                switch content {
                case .empty:
                    emptyContent
                case .image(let img, let isCover):
                    imageContent(img: img, isCover: isCover)
                case .placeholder(let emoji, let gradient, let isCover):
                    placeholderContent(emoji: emoji, gradient: gradient, isCover: isCover)
                }
            }
    }

    private var emptyContent: some View {
        Button { onAdd?() } label: {
            VStack(spacing: 4) {
                Text("+").font(.system(size: 22))
                Text("Add photo")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(Color.textSecondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .strokeBorder(
                        Color.white.opacity(0.12),
                        style: StrokeStyle(lineWidth: 2, dash: [4, 4])
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func imageContent(img: UIImage, isCover: Bool) -> some View {
        Color.bgCard
            .overlay(
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            )
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(alignment: .topLeading) {
                if isCover { coverBadge.padding(6) }
            }
            .overlay(alignment: .topTrailing) {
                removeButton.padding(6)
            }
    }

    private func placeholderContent(emoji: String, gradient: LinearGradient, isCover: Bool) -> some View {
        ZStack {
            gradient
            Text(emoji)
                .font(.system(size: 56))
                .opacity(0.55)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(alignment: .topLeading) {
            if isCover { coverBadge.padding(6) }
        }
        .overlay(alignment: .topTrailing) {
            removeButton.padding(6)
        }
    }

    private var coverBadge: some View {
        Text("COVER")
            .font(.system(size: 9, weight: .heavy))
            .tracking(0.5)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(LinearGradient.brand)
            .clipShape(Capsule())
    }

    private var removeButton: some View {
        Button { onRemove?() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(.black.opacity(0.5))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
