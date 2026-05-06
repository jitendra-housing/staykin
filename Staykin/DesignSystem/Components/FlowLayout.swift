import SwiftUI

// iOS 17+ Layout protocol — wraps chips/pills to next row when they overflow
struct FlowLayout: Layout {
    var spacing: CGFloat = Spacing.xs

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.height } + max(0, CGFloat(rows.count - 1)) * spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                let size = item.view.sizeThatFits(.unspecified)
                item.view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var items: [(view: LayoutSubview, width: CGFloat)] = []
        var height: CGFloat = 0
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? 0
        var rows: [Row] = []
        var currentRow = Row()
        var currentWidth: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            let neededWidth = currentRow.items.isEmpty ? size.width : size.width + spacing

            if currentWidth + neededWidth > maxWidth && !currentRow.items.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
                currentWidth = 0
            }

            currentRow.items.append((view: view, width: size.width))
            currentRow.height = max(currentRow.height, size.height)
            currentWidth += currentRow.items.count == 1 ? size.width : spacing + size.width
        }

        if !currentRow.items.isEmpty {
            rows.append(currentRow)
        }
        return rows
    }
}
