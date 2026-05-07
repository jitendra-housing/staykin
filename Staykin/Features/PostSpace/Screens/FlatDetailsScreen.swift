import SwiftUI

struct FlatDetailsScreen: View {
    let onContinue: () -> Void
    let onBack: () -> Void

    private let rentRange: ClosedRange<Double> = 5_000...60_000

    @State private var selectedAreas: Set<Int> = []
    @State private var rentMin: Double = 15_000
    @State private var rentMax: Double = 30_000
    @State private var selectedBHK: Set<Int> = []
    @State private var selectedFurnishing: Set<Int> = []
    @State private var flatmateCount: Int = 1
    @State private var genderPref: Int? = nil
    @State private var moveIn: Int? = nil
    @State private var amenities: Set<Int> = []

    private var canContinue: Bool {
        !selectedAreas.isEmpty
            && !selectedBHK.isEmpty
            && !selectedFurnishing.isEmpty
            && genderPref != nil
            && moveIn != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                PostStepHeader(
                    stepIndex: 0,
                    totalSteps: 3,
                    title: "Tell us about the flat 🏠",
                    onBack: onBack
                )
                .padding(.top, Spacing.sm)

                section(label: "Area", topPadding: 16) {
                    FlowLayout(spacing: Spacing.xs) {
                        ForEach(Area.allInGurgaon) { area in
                            SelectablePill(
                                label: area.name,
                                isSelected: selectedAreas.contains(area.id),
                                variant: .tag,
                                action: { selectedAreas.toggleMembership(of: area.id) }
                            )
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        SectionLabel(text: "Monthly Rent")
                        Spacer()
                        Text("\(formatRent(rentMin)) – \(formatRent(rentMax)) /mo")
                            .font(.caption1)
                            .foregroundStyle(Color.accentAmber)
                    }
                    .padding(.bottom, 36)

                    RangeSlider(
                        lowerValue: $rentMin,
                        upperValue: $rentMax,
                        range: rentRange,
                        step: 1000,
                        tooltipFormatter: formatRent
                    )

                    HStack {
                        Text("₹5K")
                        Spacer()
                        Text("₹60K+")
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(Color.textDisabled)
                    .padding(.top, Spacing.xs)
                }
                .padding(.top, 14)

                section(label: "BHK", topPadding: 14) {
                    HStack(spacing: Spacing.xs) {
                        ForEach(BHK.all) { bhk in
                            SelectablePill(
                                label: bhk.label,
                                isSelected: selectedBHK.contains(bhk.id),
                                variant: .pill,
                                action: { selectedBHK.toggleMembership(of: bhk.id) }
                            )
                        }
                        Spacer()
                    }
                }

                section(label: "Furnishing", topPadding: 14) {
                    HStack(spacing: Spacing.xs) {
                        ForEach(Furnishing.all) { f in
                            SelectablePill(
                                label: f.label,
                                isSelected: selectedFurnishing.contains(f.id),
                                variant: .pill,
                                action: { selectedFurnishing.toggleMembership(of: f.id) }
                            )
                        }
                        Spacer()
                    }
                }

                section(label: "Flatmates needed", topPadding: 14) {
                    PostStepper(value: $flatmateCount, range: 1...5, unitLabel: "flatmates")
                }

                section(label: "Gender preference", topPadding: 14) {
                    HStack(spacing: Spacing.xs) {
                        ForEach(GenderPref.all) { g in
                            SelectablePill(
                                label: g.displayLabel,
                                isSelected: genderPref == g.id,
                                variant: .pill,
                                action: { genderPref = (genderPref == g.id) ? nil : g.id }
                            )
                        }
                        Spacer()
                    }
                }

                section(label: "Move-in", topPadding: 14) {
                    HStack(spacing: Spacing.xs) {
                        ForEach(MoveInTimeline.all) { m in
                            SelectablePill(
                                label: m.displayLabel,
                                isSelected: moveIn == m.id,
                                variant: .pill,
                                action: { moveIn = (moveIn == m.id) ? nil : m.id }
                            )
                        }
                        Spacer()
                    }
                }

                section(label: "Amenities", topPadding: 14) {
                    FlowLayout(spacing: Spacing.xs) {
                        ForEach(Amenity.all) { a in
                            SelectablePill(
                                label: a.displayLabel,
                                isSelected: amenities.contains(a.id),
                                variant: .pill,
                                action: { amenities.toggleMembership(of: a.id) }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.screenHPad)
            .padding(.bottom, 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            StickyBottomCTA(title: "Next →", action: onContinue, isDisabled: !canContinue)
        }
    }

    @ViewBuilder
    private func section<Content: View>(
        label: String,
        topPadding: CGFloat,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: label)
            content()
        }
        .padding(.top, topPadding)
    }

    private func formatRent(_ v: Double) -> String { "₹\(Int(v / 1000))K" }
}

fileprivate extension Set {
    mutating func toggleMembership(of element: Element) {
        if contains(element) { remove(element) } else { insert(element) }
    }
}
