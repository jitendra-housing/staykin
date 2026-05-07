import SwiftUI

struct FlatPrefsScreen: View {
    let onContinue: () -> Void
    let onBack: () -> Void

    @Environment(OnboardingData.self) private var data

    private let budgetRange: ClosedRange<Double> = 5_000...50_000

    private var canContinue: Bool {
        !data.areas.isEmpty
            && !data.bhk.isEmpty
            && data.roomType != nil
            && !data.furnishing.isEmpty
            && data.moveIn != nil
    }

    var body: some View {
        @Bindable var data = data

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(Color.bgCard)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(Color.cardBorder, lineWidth: 1))
                }
                .padding(.top, Spacing.sm)

                StepPill(text: "Step 1 of 2")
                    .padding(.top, Spacing.md)

                Text("What are you looking for?")
                    .font(.heading1)
                    .foregroundStyle(Color.textPrimary)
                    .padding(.top, 12)

                // Area
                section(label: "Area", topPadding: 24) {
                    FlowLayout(spacing: Spacing.xs) {
                        ForEach(Area.allInGurgaon) { area in
                            SelectablePill(
                                label: area.name,
                                isSelected: data.areas.contains(area.id),
                                variant: .tag,
                                action: { toggleArea(area.id) }
                            )
                        }
                    }
                }

                // Monthly budget
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        SectionLabel(text: "Monthly Budget")
                        Spacer()
                        Text("\(formatBudget(data.budgetMin)) – \(formatBudget(data.budgetMax)) /mo")
                            .font(.caption1)
                            .foregroundStyle(Color.accentAmber)
                    }
                    .padding(.bottom, 36)

                    RangeSlider(
                        lowerValue: $data.budgetMin,
                        upperValue: $data.budgetMax,
                        range: budgetRange,
                        step: 1000,
                        tooltipFormatter: formatBudget
                    )

                    HStack {
                        Text("₹5K")
                        Spacer()
                        Text("₹50K+")
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(Color.textDisabled)
                    .padding(.top, Spacing.xs)
                }
                .padding(.top, 24)

                // BHK (multi)
                section(label: "BHK", topPadding: 24) {
                    HStack(spacing: Spacing.xs) {
                        ForEach(BHK.all) { bhk in
                            SelectablePill(
                                label: bhk.label,
                                isSelected: data.bhk.contains(bhk.id),
                                variant: .pill,
                                action: { toggle(bhk.id, in: \.bhk) }
                            )
                        }
                        Spacer()
                    }
                }

                // Room Type (single)
                section(label: "Room Type", topPadding: 24) {
                    HStack(spacing: Spacing.xs) {
                        ForEach(RoomType.all) { rt in
                            SelectablePill(
                                label: rt.displayLabel,
                                isSelected: data.roomType == rt.id,
                                variant: .pill,
                                action: { data.roomType = (data.roomType == rt.id) ? nil : rt.id }
                            )
                        }
                        Spacer()
                    }
                }

                // Furnishing (multi)
                section(label: "Furnishing", topPadding: 24) {
                    HStack(spacing: Spacing.xs) {
                        ForEach(Furnishing.all) { f in
                            SelectablePill(
                                label: f.label,
                                isSelected: data.furnishing.contains(f.id),
                                variant: .pill,
                                action: { toggle(f.id, in: \.furnishing) }
                            )
                        }
                        Spacer()
                    }
                }

                // Move-in (single)
                section(label: "Move-in", topPadding: 24) {
                    HStack(spacing: Spacing.xs) {
                        ForEach(MoveInTimeline.all) { m in
                            SelectablePill(
                                label: m.displayLabel,
                                isSelected: data.moveIn == m.id,
                                variant: .pill,
                                action: { data.moveIn = (data.moveIn == m.id) ? nil : m.id }
                            )
                        }
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, Spacing.screenHPad)
            .padding(.bottom, 100)   // clear the sticky button
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.bgBase.opacity(0), Color.bgBase],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 24)

                PrimaryButton(title: "Next →", action: onContinue, isDisabled: !canContinue)
                    .padding(.horizontal, Spacing.screenHPad)
                    .padding(.bottom, Spacing.xl)
                    .background(Color.bgBase)
            }
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

    private func toggleArea(_ id: Int) {
        if data.areas.contains(id) {
            data.areas.remove(id)
        } else {
            data.areas.insert(id)
        }
    }

    private func toggle<T: Hashable>(_ value: T, in keyPath: ReferenceWritableKeyPath<OnboardingData, Set<T>>) {
        if data[keyPath: keyPath].contains(value) {
            data[keyPath: keyPath].remove(value)
        } else {
            data[keyPath: keyPath].insert(value)
        }
    }

    private func formatBudget(_ value: Double) -> String {
        "₹\(Int(value / 1000))K"
    }
}
