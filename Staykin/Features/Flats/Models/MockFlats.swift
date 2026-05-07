import Foundation

// Mock fixtures used until GET /flats and GET /flats/:id are wired in.
// Keep these in sync with sample payloads in docs/api/flats.md.
enum MockFlats {
    static let list: [Flat] = [
        .init(
            id: 101, typeId: FlatType.privateRoom.id,
            locality: "DLF Phase 1", rent: 18_000, score: 92,
            amenityIds: [Amenity.furnished.id, Amenity.ac.id, Amenity.attachedBath.id],
            photoURL: nil, photoHue: 280, photoHue2: 320, photoEmoji: "🛏",
            verified: true, availableNow: true
        ),
        .init(
            id: 102, typeId: FlatType.privateRoom.id,
            locality: "Sector 46", rent: 14_000, score: 88,
            amenityIds: [Amenity.furnished.id, Amenity.wfhReady.id, Amenity.parking.id],
            photoURL: nil, photoHue: 220, photoHue2: 280, photoEmoji: "🪴",
            verified: true, availableNow: true
        ),
        .init(
            id: 103, typeId: FlatType.sharedRoom.id,
            locality: "Cyber City", rent: 9_000, score: 84,
            amenityIds: [Amenity.pool.id, Amenity.gym.id, Amenity.lift.id],
            photoURL: nil, photoHue: 30, photoHue2: 350, photoEmoji: "🛌",
            verified: false, availableNow: true
        ),
        .init(
            id: 104, typeId: FlatType.privateRoom.id,
            locality: "Golf Course Road", rent: 16_000, score: 78,
            amenityIds: [Amenity.furnished.id, Amenity.balcony.id, Amenity.cctv.id],
            photoURL: nil, photoHue: 320, photoHue2: 30, photoEmoji: "🛋",
            verified: true, availableNow: false
        ),
        .init(
            id: 105, typeId: FlatType.privateRoom.id,
            locality: "Sushant Lok 1", rent: 15_000, score: 82,
            amenityIds: [Amenity.wifi.id, Amenity.ac.id, Amenity.washer.id],
            photoURL: nil, photoHue: 200, photoHue2: 260, photoEmoji: "🏠",
            verified: true, availableNow: true
        ),
        .init(
            id: 106, typeId: FlatType.sharedRoom.id,
            locality: "Manesar", rent: 8_000, score: 76,
            amenityIds: [Amenity.parking.id, Amenity.geyser.id],
            photoURL: nil, photoHue: 140, photoHue2: 200, photoEmoji: "🛌",
            verified: false, availableNow: true
        )
    ]

    static let detail = FlatDetail(
        id: 101, typeId: FlatType.privateRoom.id,
        locality: "DLF Phase 1", addressLine: "5th floor, Skylark Apartments",
        rent: 45_000,
        bhkId: BHK.threeBHK.id, furnishingId: Furnishing.furnished.id,
        areaSqft: 1450, verified: true, availableNow: true, score: 92,
        photos: [
            .init(id: 1, url: nil, placeholderHue: 220, placeholderHue2: 280, placeholderEmoji: "🏢"),
            .init(id: 2, url: nil, placeholderHue: 200, placeholderHue2: 260, placeholderEmoji: "🛋"),
            .init(id: 3, url: nil, placeholderHue: 280, placeholderHue2: 320, placeholderEmoji: "🪴"),
            .init(id: 4, url: nil, placeholderHue: 30,  placeholderHue2: 60,  placeholderEmoji: "🍳")
        ],
        amenityIds: Amenity.all.map(\.id),
        flatmates: [
            .init(
                id: 21, name: "Aarav", age: 26, role: .poster,
                job: "Product @ Razorpay",
                emoji: "🦊", avatarURL: nil, avatarHue: 30, avatarHue2: 60,
                matchPct: 79,
                vibePrefIds: [
                    VibePref.all.first { $0.value == "EARLY_BIRDS" }!.id,
                    VibePref.all.first { $0.value == "CLEAN_FREAK" }!.id,
                    VibePref.all.first { $0.value == "WFH_GRIND" }!.id,
                    VibePref.all.first { $0.value == "FOODIES" }!.id,
                    VibePref.all.first { $0.value == "PET_FRIENDLY" }!.id,
                    VibePref.all.first { $0.value == "MUSIC_HEADS" }!.id
                ],
                bio: "your friendly neighbourhood PM. early to rise, in bed by 11. love a clean kitchen and a slow saturday morning ☕",
                lookingFor: [
                    .init(label: "Move-in", value: "1 May 2026"),
                    .init(label: "Lease",   value: "11 months min"),
                    .init(label: "Vibe",    value: "Chill, working pros")
                ]
            ),
            .init(
                id: 22, name: "Priya", age: 24, role: .flatmate,
                job: "Marketing @ Swiggy",
                emoji: "🌸", avatarURL: nil, avatarHue: 320, avatarHue2: 280,
                matchPct: 87,
                vibePrefIds: [
                    VibePref.all.first { $0.value == "LATE_NIGHTS" }!.id,
                    VibePref.all.first { $0.value == "CREATIVE" }!.id,
                    VibePref.all.first { $0.value == "PET_FRIENDLY" }!.id,
                    VibePref.all.first { $0.value == "FOODIES" }!.id,
                    VibePref.all.first { $0.value == "PLANT_PARENTS" }!.id,
                    VibePref.all.first { $0.value == "WFH_GRIND" }!.id
                ],
                bio: "chronic plant parent (i have 23, send help). work in marketing but built like a designer. won't judge ur 3am biryani 🥲",
                lookingFor: [
                    .init(label: "Move-in", value: "Already in"),
                    .init(label: "Stay",    value: "Long term"),
                    .init(label: "Vibes",   value: "Creative + cozy")
                ]
            )
        ],
        combinedMatch: .init(score: 83, summary: "Strong vibe", participants: ["You", "Aarav", "Priya"]),
        slots: .init(total: 3, filled: 2),
        privateRoom: .init(rentShare: 15_000, availableNow: true),
        about: "Spacious 3BHK in a quiet society with sunlit balconies, modular kitchen and gated parking. Walking distance to metro, cafés and weekend markets. Looking for friendly working professionals or students who keep things tidy and respect quiet hours. Pets are welcome."
    )

    // Swipe deck candidates for the Flatmates tab.
    static let swipeFeed: [Flatmate] = [
        .init(
            id: 201, name: "Priya", age: 24, role: .flatmate,
            job: "Marketing @ Swiggy",
            emoji: "🌸", avatarURL: nil, avatarHue: 320, avatarHue2: 280,
            matchPct: 91,
            vibePrefIds: [1, 7, 13, 6, 9, 2].compactMap { id in
                VibePref.find(by: id)?.id
            },
            bio: "Plant parent, designer-at-heart, late-night ramen kind of girl.",
            lookingFor: [
                .init(label: "Move-in", value: "Within 1 month"),
                .init(label: "Stay",    value: "11 months+"),
                .init(label: "Areas",   value: "DLF Phase 1, Cyber City")
            ]
        ),
        .init(
            id: 202, name: "Aarav", age: 26, role: .flatmate,
            job: "Product @ Razorpay",
            emoji: "🦊", avatarURL: nil, avatarHue: 30, avatarHue2: 60,
            matchPct: 88,
            vibePrefIds: [8, 20, 2, 6, 9, 3].compactMap { VibePref.find(by: $0)?.id },
            bio: "Early to rise, slow saturday mornings, won't judge your kombucha phase.",
            lookingFor: [
                .init(label: "Move-in", value: "ASAP"),
                .init(label: "Stay",    value: "Long term"),
                .init(label: "Areas",   value: "Sector 46, Golf Course Road")
            ]
        ),
        .init(
            id: 203, name: "Ishaan", age: 28, role: .flatmate,
            job: "Engineer @ Google",
            emoji: "🦄", avatarURL: nil, avatarHue: 220, avatarHue2: 260,
            matchPct: 84,
            vibePrefIds: [2, 22, 16, 14, 21, 19].compactMap { VibePref.find(by: $0)?.id },
            bio: "WFH mostly, gym 5x a week, weekend hikes when the smog allows.",
            lookingFor: [
                .init(label: "Move-in", value: "1–3 months"),
                .init(label: "Stay",    value: "1 year+"),
                .init(label: "Areas",   value: "Cyber City, Sushant Lok 1")
            ]
        ),
        .init(
            id: 204, name: "Meera", age: 25, role: .flatmate,
            job: "Designer @ Zomato",
            emoji: "🪻", avatarURL: nil, avatarHue: 180, avatarHue2: 230,
            matchPct: 86,
            vibePrefIds: [13, 1, 11, 5, 17, 18].compactMap { VibePref.find(by: $0)?.id },
            bio: "Quiet vibes, lots of plants, occasional dinner-party host.",
            lookingFor: [
                .init(label: "Move-in", value: "Within 1 month"),
                .init(label: "Stay",    value: "Long term"),
                .init(label: "Areas",   value: "DLF Phase 1, Sushant Lok 1")
            ]
        ),
        .init(
            id: 205, name: "Rohan", age: 27, role: .flatmate,
            job: "Founder, stealth",
            emoji: "🦁", avatarURL: nil, avatarHue: 80, avatarHue2: 130,
            matchPct: 79,
            vibePrefIds: [2, 14, 15, 12, 22, 23].compactMap { VibePref.find(by: $0)?.id },
            bio: "Building something quietly. Hosts often, loves a long walk and a strong filter coffee.",
            lookingFor: [
                .init(label: "Move-in", value: "ASAP"),
                .init(label: "Stay",    value: "Open"),
                .init(label: "Areas",   value: "Cyber City, Golf Course Road")
            ]
        ),
        .init(
            id: 206, name: "Ananya", age: 23, role: .flatmate,
            job: "Grad student @ IIT-D",
            emoji: "🌻", avatarURL: nil, avatarHue: 40, avatarHue2: 350,
            matchPct: 82,
            vibePrefIds: [4, 21, 5, 11, 18, 9].compactMap { VibePref.find(by: $0)?.id },
            bio: "Bookworm by night, runner by morning. Tea > coffee, always.",
            lookingFor: [
                .init(label: "Move-in", value: "Next month"),
                .init(label: "Stay",    value: "Academic year"),
                .init(label: "Areas",   value: "Sector 46, South City 1")
            ]
        )
    ]
}
