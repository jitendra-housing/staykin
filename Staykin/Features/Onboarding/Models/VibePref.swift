import Foundation

// Canonical lifestyle preferences. `id` and `value` come from the backend
// (`Message Jitendra Lakhmani`); `emoji` is iOS-side display only.
struct VibePref: Identifiable, Hashable {
    let id: Int
    let value: String
    let label: String
    let emoji: String
}

extension VibePref {
    static let minSelections = 5

    static let all: [VibePref] = [
        .init(id: 1,  value: "PLANT_PARENTS",  label: "Plant parents",  emoji: "🪴"),
        .init(id: 2,  value: "WFH_GRIND",      label: "WFH grind",      emoji: "💼"),
        .init(id: 3,  value: "MUSIC_HEADS",    label: "Music heads",    emoji: "🎸"),
        .init(id: 4,  value: "BOOKWORM",       label: "Bookworm",       emoji: "📚"),
        .init(id: 5,  value: "YOGA_CHAI",      label: "Yoga + chai",    emoji: "🧘"),
        .init(id: 6,  value: "FOODIES",        label: "Foodies",        emoji: "🍳"),
        .init(id: 7,  value: "LATE_NIGHTS",    label: "Late nights",    emoji: "🦉"),
        .init(id: 8,  value: "EARLY_BIRDS",    label: "Early birds",    emoji: "🌅"),
        .init(id: 9,  value: "PET_FRIENDLY",   label: "Pet friendly",   emoji: "🐶"),
        .init(id: 10, value: "SMOKE_FREE",     label: "Smoke free",     emoji: "🚭"),
        .init(id: 11, value: "QUIET_VIBES",    label: "Quiet vibes",    emoji: "🤫"),
        .init(id: 12, value: "PARTY_OK",       label: "Party ok",       emoji: "🥳"),
        .init(id: 13, value: "CREATIVE",       label: "Creative",       emoji: "🎨"),
        .init(id: 14, value: "OUTDOORSY",      label: "Outdoorsy",      emoji: "🏞️"),
        .init(id: 15, value: "HOSTS_OFTEN",    label: "Hosts often",    emoji: "🍻"),
        .init(id: 16, value: "FITNESS_FREAK",  label: "Fitness freak",  emoji: "🏋️"),
        .init(id: 17, value: "VEGAN",          label: "Vegan",          emoji: "🌱"),
        .init(id: 18, value: "NON_ALCOHOLIC",  label: "Non-alcoholic",  emoji: "🚫"),
        .init(id: 19, value: "WANDERER",       label: "Wanderer",       emoji: "✈️"),
        .init(id: 20, value: "CLEAN_FREAK",    label: "Clean freak",    emoji: "🧹"),
        .init(id: 21, value: "CHILL_VIBES",    label: "Chill vibes",    emoji: "😌"),
        .init(id: 22, value: "GAMERS",         label: "Gamers",         emoji: "🎮"),
        .init(id: 23, value: "MOVIE_NIGHTS",   label: "Movie nights",   emoji: "🎬"),
        .init(id: 24, value: "SPORTY",         label: "Sporty",         emoji: "⚽")
    ]

    static func find(by id: Int) -> VibePref? {
        all.first { $0.id == id }
    }
}
