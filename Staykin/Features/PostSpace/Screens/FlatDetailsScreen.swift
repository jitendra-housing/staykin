import SwiftUI

struct FlatDetailsScreen: View {
    let onContinue: () -> Void
    let onBack: () -> Void

    @Environment(OnboardingData.self) private var data

    private var canContinue: Bool {
        data.listingLocalityId != nil
            && data.listingMonthlyRent != nil
            && data.listingBHK != nil
            && data.listingFurnishing != nil
            && data.listingRoomType != nil
            && data.listingGenderPref != nil
            && data.listingMoveIn != nil
    }

    var body: some View {
        @Bindable var data = data

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
                                isSelected: data.listingLocalityId == area.id,
                                variant: .tag,
                                action: { data.listingLocalityId = (data.listingLocalityId == area.id) ? nil : area.id }
                            )
                        }
                    }
                }

                section(label: "Monthly Rent", topPadding: 14) {
                    rentField
                }

                section(label: "BHK", topPadding: 14) {
                    HStack(spacing: Spacing.xs) {
                        ForEach(BHK.all) { bhk in
                            SelectablePill(
                                label: bhk.label,
                                isSelected: data.listingBHK == bhk.id,
                                variant: .pill,
                                action: { data.listingBHK = (data.listingBHK == bhk.id) ? nil : bhk.id }
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
                                isSelected: data.listingFurnishing == f.id,
                                variant: .pill,
                                action: { data.listingFurnishing = (data.listingFurnishing == f.id) ? nil : f.id }
                            )
                        }
                        Spacer()
                    }
                }

                section(label: "Room Type", topPadding: 14) {
                    HStack(spacing: Spacing.xs) {
                        ForEach([RoomType.singleRoom, RoomType.sharing]) { rt in
                            SelectablePill(
                                label: rt.label,
                                isSelected: data.listingRoomType == rt.id,
                                variant: .pill,
                                action: { data.listingRoomType = (data.listingRoomType == rt.id) ? nil : rt.id }
                            )
                        }
                        Spacer()
                    }
                }

                section(label: "Flatmates needed", topPadding: 14) {
                    PostStepper(value: $data.listingFlatmatesNeeded, range: 1...5, unitLabel: "flatmates")
                }

                section(label: "Gender preference", topPadding: 14) {
                    HStack(spacing: Spacing.xs) {
                        ForEach(GenderPref.all) { g in
                            SelectablePill(
                                label: g.displayLabel,
                                isSelected: data.listingGenderPref == g.id,
                                variant: .pill,
                                action: { data.listingGenderPref = (data.listingGenderPref == g.id) ? nil : g.id }
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
                                isSelected: data.listingMoveIn == m.id,
                                variant: .pill,
                                action: { data.listingMoveIn = (data.listingMoveIn == m.id) ? nil : m.id }
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
                                isSelected: data.listingAmenities.contains(a.id),
                                variant: .pill,
                                action: { data.listingAmenities.toggleMembership(of: a.id) }
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

    // MARK: - Rent input

    private var rentField: some View {
        HStack(spacing: 8) {
            Text("₹")
                .font(.bodyLg.weight(.semibold))
                .foregroundStyle(Color.textSecondary)

            TextField(
                "",
                text: rentText,
                prompt: Text("e.g. 25000").foregroundStyle(Color.textDisabled)
            )
            .font(.bodyLg)
            .foregroundStyle(Color.textPrimary)
            .keyboardType(.numberPad)

            Text("/ mo")
                .font(.bodySm)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: ComponentSize.inputHeight)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .strokeBorder(Color.cardBorder, lineWidth: 1)
        )
    }

    private var rentText: Binding<String> {
        Binding(
            get: { data.listingMonthlyRent.map(String.init) ?? "" },
            set: { newValue in
                let digits = newValue.filter(\.isNumber).prefix(7)
                data.listingMonthlyRent = digits.isEmpty ? nil : Int(digits)
            }
        )
    }

    // MARK: - Helpers

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
}

fileprivate extension Set {
    mutating func toggleMembership(of element: Element) {
        if contains(element) { remove(element) } else { insert(element) }
    }
}
