import SwiftUI

struct FlatmatesSwipeView: View {
    let candidates: [Flatmate]

    @State private var removedIds: Set<Int> = []
    @State private var lastRequestedName: String? = nil
    @State private var showToast = false

    private let visibleStackDepth = 3

    private var visibleCandidates: [Flatmate] {
        candidates.filter { !removedIds.contains($0.id) }
    }

    private var visibleSlice: [Flatmate] {
        Array(visibleCandidates.prefix(visibleStackDepth))
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ZStack {
                if visibleCandidates.isEmpty {
                    emptyState
                } else {
                    deck
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 18)
            .padding(.bottom, 24)
        }
        .background(Color.bgBase)
        .overlay(alignment: .bottom) {
            if showToast, let name = lastRequestedName {
                SuccessToast(title: "Request sent to \(name)")
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.25), value: showToast)
        .task(id: showToast) {
            guard showToast else { return }
            try? await Task.sleep(for: .seconds(2.5))
            if !Task.isCancelled {
                showToast = false
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Flatmates")
                .font(.heading1)
                .foregroundStyle(Color.textPrimary)
            Spacer()
            Text("\(visibleCandidates.count) nearby")
                .font(.caption1)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 14)
    }

    // MARK: - Deck

    private var deck: some View {
        ZStack {
            ForEach(Array(visibleSlice.enumerated()).reversed(), id: \.element.id) { offset, mate in
                let isTop = offset == 0
                SwipeableFlatmateCard(
                    flatmate: mate,
                    isInteractive: isTop,
                    onSwiped: { decision in
                        handleSwipe(of: mate, decision: decision)
                    }
                )
                .scaleEffect(1 - CGFloat(offset) * 0.04)
                .offset(y: CGFloat(offset) * 10)
                .allowsHitTesting(isTop)
                .zIndex(Double(visibleStackDepth - offset))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: visibleCandidates.map(\.id))
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Text("🎉").font(.system(size: 64))
            Text("That's everyone for now")
                .font(.heading2)
                .foregroundStyle(Color.textPrimary)
            Text("Check back later for new flatmates")
                .font(.bodyLg)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    // MARK: - Actions

    private func handleSwipe(of mate: Flatmate, decision: SwipeableFlatmateCard.SwipeDecision) {
        removedIds.insert(mate.id)
        if decision == .requestSent {
            lastRequestedName = mate.name
            showToast = true
        }
    }
}
