import SwiftUI

struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.caption1)
            .foregroundStyle(Color.textSecondary)
            .tracking(1.2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
