import SwiftUI

// Standard Staykin bottom sheet — drag handle, dark sheet bg, 28pt corners.
// Uses native iOS 16.4+ presentation APIs.
extension View {
    func staykinSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.large],
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            content()
                .presentationDetents(detents)
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.bgSheet)
                .presentationCornerRadius(28)
        }
    }

    func staykinSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        detents: Set<PresentationDetent> = [.large],
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        self.sheet(item: item) { value in
            content(value)
                .presentationDetents(detents)
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.bgSheet)
                .presentationCornerRadius(28)
        }
    }
}
