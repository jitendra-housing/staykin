import SwiftUI

// Phase A placeholder. Phase B replaces this with the real Flats Tab list.
struct FlatsTabPlaceholder: View {
    var body: some View {
        TabPlaceholder(
            emoji: "🏠",
            title: "Flats",
            subtitle: "Phase B will show \(MockFlats.list.count) flats here"
        )
    }
}
