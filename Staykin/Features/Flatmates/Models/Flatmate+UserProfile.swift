import Foundation

// Adapter from server-shaped UserProfile → the richer Flatmate display model
// used by SwipeableFlatmateCard / FlatmatesSwipeView and the chat header.
// matchPct comes from UserProfile.vibeScore (a `vibe_score` field on the
// server-side UserOut once backend ships it). Falls back to 0 until then.
extension Flatmate {
    init(profile: UserProfile) {
        let hue = Double((profile.id * 47) % 360)
        let occupationName = profile.occupation
            .flatMap { Occupation.find(by: $0)?.name } ?? ""

        var lookingFor: [LookingForItem] = []
        if let min = profile.budgetMin, let max = profile.budgetMax {
            lookingFor.append(.init(label: "Budget", value: "₹\(min / 1000)–\(max / 1000)K /mo"))
        }
        let bhkLabels = (profile.bhkPrefs ?? []).compactMap { BHK.find(by: $0)?.label }
        if !bhkLabels.isEmpty {
            lookingFor.append(.init(label: "Type", value: bhkLabels.joined(separator: " · ")))
        }
        let areaNames = (profile.preferredLocalityIds ?? [])
            .compactMap { Area.find(by: $0)?.name }
            .prefix(3)
        if !areaNames.isEmpty {
            lookingFor.append(.init(label: "Areas", value: areaNames.joined(separator: ", ")))
        }
        if let moveInId = profile.moveInPref,
           let moveIn = MoveInTimeline.find(by: moveInId) {
            lookingFor.append(.init(label: "Move-in", value: moveIn.displayLabel))
        }

        self.init(
            id: profile.id,
            name: profile.name ?? "Flatmate",
            age: profile.age ?? 0,
            role: .flatmate,
            job: occupationName,
            emoji: nil,
            avatarURL: profile.photoUrl,
            avatarHue: hue,
            avatarHue2: (hue + 50).truncatingRemainder(dividingBy: 360),
            matchPct: profile.vibeScore ?? 0,             // backend wires vibe_score → UserOut; 0 until then
            vibePrefIds: profile.lifestyleTagIds ?? [],
            bio: "",                                      // not returned by /flatmates
            lookingFor: lookingFor
        )
    }
}
