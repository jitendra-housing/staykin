import SwiftUI
import PhotosUI

struct PhotosScreen: View {
    let onContinue: () -> Void
    let onBack: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    @State private var photos: [UIImage] = []
    @State private var pickerItem: PhotosPickerItem?
    @State private var showPicker: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                PostStepHeader(
                    stepIndex: 1,
                    totalSteps: 3,
                    title: "Add some photos 📸",
                    subtitle: "Listings with 5+ photos get 3× more enquiries ✨",
                    onBack: onBack
                )
                .padding(.top, Spacing.sm)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<6, id: \.self) { i in
                        photoCell(at: i)
                    }
                }
                .padding(.top, 22)

                TipBanner(
                    variant: .amber,
                    emoji: "💡",
                    leadText: "Pro tip:",
                    text: "shoot in daylight, declutter the frame, and capture the bathroom too 🤝"
                )
                .padding(.top, 22)
            }
            .padding(.horizontal, Spacing.screenHPad)
            .padding(.bottom, 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            StickyBottomCTA(title: "Next →", action: onContinue)
        }
        .photosPicker(isPresented: $showPicker, selection: $pickerItem, matching: .images)
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { @MainActor in
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    photos.append(uiImage)
                }
                pickerItem = nil
            }
        }
    }

    @ViewBuilder
    private func photoCell(at index: Int) -> some View {
        if index < photos.count {
            PhotoTile(
                content: .image(photos[index], isCover: index == 0),
                onRemove: { photos.remove(at: index) }
            )
        } else {
            PhotoTile(content: .empty, onAdd: { showPicker = true })
        }
    }
}
