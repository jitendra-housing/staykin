import SwiftUI
import PhotosUI

struct PhotosScreen: View {
    let onContinue: () async -> Void
    let onBack: () -> Void

    @Environment(OnboardingData.self) private var data

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private struct PhotoSlot: Identifiable {
        let id = UUID()
        let image: UIImage
        var url: String?
    }

    @State private var slots: [PhotoSlot] = []
    @State private var pickerItem: PhotosPickerItem?
    @State private var showPicker: Bool = false
    @State private var isSubmitting: Bool = false

    private var isUploading: Bool { slots.contains { $0.url == nil } }
    private var ctaTitle: String {
        if isSubmitting { return "" }
        if isUploading { return "Uploading photos…" }
        return "Next →"
    }

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
            StickyBottomCTA(
                title: ctaTitle,
                action: handleContinue,
                isDisabled: isUploading,
                isLoading: isSubmitting
            )
        }
        .photosPicker(isPresented: $showPicker, selection: $pickerItem, matching: .images)
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { @MainActor in
                if let imageData = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: imageData) {
                    let slot = PhotoSlot(image: uiImage, url: nil)
                    slots.append(slot)
                    let slotId = slot.id
                    do {
                        let url = try await UploadsAPI.uploadImage(imageData, folder: "listings")
                        if let idx = slots.firstIndex(where: { $0.id == slotId }) {
                            slots[idx].url = url
                            data.flatPhotoUrls = slots.compactMap(\.url)
                        }
                    } catch {
                        print("flat photo upload failed: \(error)")
                    }
                }
                pickerItem = nil
            }
        }
    }

    private func removeSlot(at index: Int) {
        slots.remove(at: index)
        data.flatPhotoUrls = slots.compactMap(\.url)
    }

    private func handleContinue() {
        guard !isSubmitting else { return }
        isSubmitting = true
        Task { @MainActor in
            await onContinue()
            isSubmitting = false
        }
    }

    @ViewBuilder
    private func photoCell(at index: Int) -> some View {
        if index < slots.count {
            PhotoTile(
                content: .image(slots[index].image, isCover: index == 0),
                isUploading: slots[index].url == nil,
                onRemove: { removeSlot(at: index) }
            )
        } else {
            PhotoTile(content: .empty, onAdd: { showPicker = true })
        }
    }
}
