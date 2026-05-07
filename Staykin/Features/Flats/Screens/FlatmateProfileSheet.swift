import SwiftUI

struct FlatmateProfileSheet: View {
    let flatmate: Flatmate
    let onClose: () -> Void

    var body: some View {
        ScrollView {
            FlatmateVibeCard(flatmate: flatmate)
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 18)
        }
        .background(Color.bgSheet)
    }
}
