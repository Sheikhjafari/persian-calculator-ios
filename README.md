# Persian Calculator for iPhone

A SwiftUI addition/subtraction calculator with Persian digits and exact decimal arithmetic. Supports iOS 16 and later. No network services or external libraries are used by the app.

## Cloud build

Run **Build iPhone calculator** in GitHub Actions, or push a native code change to `main`. The workflow tests the arithmetic, builds the device app using Xcode 26.3, packages an unsigned IPA, then builds and launches a simulator preview.

Download the `Calculator-iPhone-unsigned` artifact from a successful run. `Calculator-unsigned.ipa` must be signed with your Apple account using a sideloading tool such as iloader before installing on a physical device. The artifact also contains a checksum and build metadata. A separate `Calculator-simulator-preview` artifact contains the simulator screenshot. The IPA is uploaded before the simulator check so it remains available if simulator startup fails. Free-account signing expires after seven days.

No Apple credentials or signing certificates are needed in GitHub Actions. Use standard macOS runners in a public repository for free hosted execution. Artifacts expire after seven days; keep a local copy.

## Local development

Open `native/Calculator.xcodeproj` in Xcode on a compatible Mac. See `native/README.md` for Persian instructions. Run `swift test --package-path native` to compare the core with 16,014 reference states from the original web calculator.

The web arithmetic reference is retained at `web/calculator.js` for fixture regeneration.
