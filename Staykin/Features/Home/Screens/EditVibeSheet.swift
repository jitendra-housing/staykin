import SwiftUI

struct EditVibeSheet: View {
    let onSaved: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selected: Set<Int>
    @State private var isSaving = false
    @State private var alertMessage: String?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    init(initial: Set<Int>, onSaved: @escaping () -> Void) {
        self.onSaved = onSaved
        _selected = State(initialValue: initial)
    }

    private var canSave: Bool { selected.count >= VibePref.minSelections }
    private var ctaTitle: String {
        if isSaving { return "" }
        return canSave
            ? "Save my vibe ✨"
            : "Pick \(VibePref.minSelections - selected.count) more"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("What's your vibe? ✨")
                        .font(.heading1)
                        .foregroundStyle(Color.textPrimary)
                        .padding(.top, Spacing.sm)

                    Text("Pick at least 5 — helps us match you with the right people")
                        .font(.bodySm)
                        .foregroundStyle(Color.textSecondary)
                        .padding(.top, 6)

                    HStack {
                        SectionLabel(text: "Pick your vibe")
                        Spacer()
                        Text("\(selected.count)/\(VibePref.minSelections) minimum")
                            .font(.caption1.weight(.bold))
                            .foregroundStyle(canSave ? Color.success : Color.accentAmber)
                    }
                    .padding(.top, 22)
                    .padding(.bottom, 14)

                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(VibePref.all) { pref in
                            VibeTile(
                                emoji: pref.emoji,
                                label: pref.label,
                                isSelected: selected.contains(pref.id),
                                action: { toggle(pref.id) }
                            )
                        }
                    }
                }
                .padding(.horizontal, Spacing.screenHPad)
                .padding(.bottom, 120)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.bgBase)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.primaryPurple)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                StickyBottomCTA(
                    title: ctaTitle,
                    action: handleSave,
                    isDisabled: !canSave || isSaving,
                    isLoading: isSaving
                )
            }
            .alert(
                "Couldn't save",
                isPresented: Binding(
                    get: { alertMessage != nil },
                    set: { if !$0 { alertMessage = nil } }
                ),
                actions: { Button("OK", role: .cancel) {} },
                message: { Text(alertMessage ?? "") }
            )
        }
    }

    private func toggle(_ id: Int) {
        if selected.contains(id) { selected.remove(id) }
        else { selected.insert(id) }
    }

    private func handleSave() {
        guard !isSaving else { return }
        isSaving = true
        Task { @MainActor in
            await save()
            isSaving = false
        }
    }

    @MainActor
    private func save() async {
        let data = OnboardingData()
        data.userId = UserStore.saved?.id
            ?? (UserDefaults.standard.object(forKey: OnboardingAPI.userIdDefaultsKey) as? Int)
        data.vibePrefs = selected
        do {
            try await OnboardingAPI.patchProfile(data)
            onSaved()
            dismiss()
        } catch {
            alertMessage = error.localizedDescription
        }
    }
}
