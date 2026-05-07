import Foundation

enum OnboardingRoute: Hashable {
    case phone        // 1. What's your number?
    case otp          // 2. Enter the code
    case profile      // 3. Let's set up your profile
    case intent       // 4. What are you here for?

    // Move-in / Team-up branch
    case flatPrefs    // 5. What are you looking for? (Step 1 of 2)
    case vibeForm     // 6. Choose your preferences (Step 2 of 2)
    case vibeCard     // 7. Your vibe card is ready

    // Fill-rooms branch — Post your Space
    case postFlatDetails
    case postPhotos
    case postVibe
    case postSuccess
}
