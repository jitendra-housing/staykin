import SwiftUI

// Re-exported alias so HomeView keeps mounting `FlatmatesTabPlaceholder` —
// the real swipe deck lives in Features/Flatmates/.
struct FlatmatesTabPlaceholder: View {
    var body: some View {
        FlatmatesSwipeView()
    }
}
