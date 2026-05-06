import SwiftUI
import PhotosUI

struct ProfileScreen: View {
    let onContinue: () -> Void

    @Environment(OnboardingData.self) private var data
    @State private var photoItem: PhotosPickerItem?

    private let cities = [
        "Bengaluru", "Mumbai", "Delhi", "Hyderabad", "Pune",
        "Chennai", "Gurgaon", "Noida", "Kolkata", "Ahmedabad"
    ]

    private var canContinue: Bool {
        !data.name.trimmingCharacters(in: .whitespaces).isEmpty
            && data.age != nil
            && data.gender != nil
            && !data.occupation.trimmingCharacters(in: .whitespaces).isEmpty
            && !data.city.isEmpty
    }

    var body: some View {
        @Bindable var data = data

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Let's set up your profile 🪩")
                    .font(.heading1)
                    .foregroundStyle(Color.textPrimary)
                    .padding(.top, 24)

                Text("Just the basics, we'll vibe-check the rest")
                    .font(.bodySm)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.top, 6)

                // Photo picker
                HStack {
                    Spacer()
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            ZStack {
                                Circle().fill(Color.bgCard)
                                Circle().strokeBorder(
                                    Color.white.opacity(0.15),
                                    style: StrokeStyle(lineWidth: 2, dash: [4, 4])
                                )
                                if let imageData = data.photoData,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                } else {
                                    Text("📷").font(.system(size: 28))
                                }
                            }
                            .frame(width: 96, height: 96)

                            Text("✏️")
                                .font(.system(size: 14))
                                .frame(width: 32, height: 32)
                                .background(LinearGradient.brand)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().strokeBorder(Color.bgBase, lineWidth: 3)
                                )
                                .offset(x: 2, y: 2)
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.top, 28)

                VStack(spacing: 12) {
                    StaykinTextField(
                        placeholder: "Full name",
                        text: $data.name,
                        autocapitalization: .words
                    )

                    HStack(spacing: 10) {
                        AgeField(age: $data.age)
                            .frame(width: 90)
                        DropdownField(
                            placeholder: "Gender",
                            value: data.gender?.rawValue,
                            options: Gender.allCases.map { ($0.rawValue, $0) }
                        ) { selected in
                            data.gender = selected
                        }
                        .frame(maxWidth: .infinity)
                    }

                    StaykinTextField(
                        placeholder: "Occupation",
                        text: $data.occupation,
                        autocapitalization: .words
                    )

                    DropdownField(
                        placeholder: "City",
                        value: data.city.isEmpty ? nil : data.city,
                        options: cities.map { ($0, $0) }
                    ) { selected in
                        data.city = selected
                    }
                }
                .padding(.top, 28)

                PrimaryButton(title: "Next →", action: onContinue, isDisabled: !canContinue)
                    .padding(.top, 28)
                    .padding(.bottom, Spacing.xl)
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBase)
        .navigationBarBackButtonHidden(true)
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task { @MainActor in
                if let imageData = try? await item.loadTransferable(type: Data.self) {
                    data.photoData = imageData
                }
            }
        }
    }
}

// MARK: - Age field (90px, number pad)

private struct AgeField: View {
    @Binding var age: Int?
    @FocusState private var focused: Bool

    private var text: Binding<String> {
        Binding(
            get: { age.map(String.init) ?? "" },
            set: { newValue in
                let digits = newValue.filter(\.isNumber).prefix(2)
                age = digits.isEmpty ? nil : Int(digits)
            }
        )
    }

    var body: some View {
        TextField("", text: text, prompt: Text("Age").foregroundStyle(Color.textDisabled))
            .font(.bodyLg)
            .foregroundStyle(Color.textPrimary)
            .keyboardType(.numberPad)
            .focused($focused)
            .padding(.horizontal, Spacing.md)
            .frame(height: ComponentSize.inputHeight)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .strokeBorder(
                        focused ? Color.primaryPurple.opacity(0.6) : Color.cardBorder,
                        lineWidth: 1
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: focused)
    }
}

// MARK: - Dropdown field (Menu-backed picker styled like StaykinTextField)

private struct DropdownField<Value: Hashable>: View {
    let placeholder: String
    let value: String?
    let options: [(label: String, value: Value)]
    let onSelect: (Value) -> Void

    var body: some View {
        Menu {
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                Button(option.label) { onSelect(option.value) }
            }
        } label: {
            HStack {
                Text(value ?? placeholder)
                    .font(.bodyLg)
                    .foregroundStyle(value == nil ? Color.textDisabled : Color.textPrimary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
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
    }
}
