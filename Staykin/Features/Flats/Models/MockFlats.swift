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
}
