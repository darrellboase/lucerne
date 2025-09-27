# Lucerne Herbicides – iOS App

This folder contains SwiftUI source files for an iOS app that provides an interactive database of herbicides usable in lucerne (alfalfa), with search and filters (type, phytotoxicity, application timing, specific weeds).

Because iOS builds require Xcode on macOS, use the steps below on a Mac (or cloud Mac) to create a signed, exportable build for iPhone.

## Files
- `HerbicideGuideApp.swift` – App entry point
- `Models/Herbicide.swift` – Data model and in-memory store with sample data
- `Views/ContentView.swift` – Searchable list + filter button
- `Views/HerbicideDetailView.swift` – Detailed view with sections and flow layout tags
- `Views/FilterView.swift` – Multi-select filters for Type, Phytotoxicity, Timing, and Weeds
- `Assets.xcassets/` – Placeholder asset catalog with `AppIcon.appiconset` (add real app icons here once in Xcode)
- `project.yml` – XcodeGen manifest (iPhone-only target)
- `Config/Info.plist` – Minimal Info.plist configured for iPhone

## Generate the Xcode project (iPhone only)
This repo includes a preconfigured XcodeGen manifest (`project.yml`). On a Mac:

1. Install XcodeGen (one-time):
   - Using Homebrew: `brew install xcodegen`
2. In Terminal, navigate to this folder (`HerbicideGuide/`) and run:
   - `xcodegen generate`
3. Open the generated `LucerneHerbicides.xcodeproj` in Xcode.

Notes
- The generated target is iPhone-only (`TARGETED_DEVICE_FAMILY=1`) and Mac Catalyst is disabled.
- The app icon set is wired to `Assets.xcassets/AppIcon.appiconset`.

## Add App Icons (iPhone only)
In Xcode, select the `AppIcon` set and drop PNGs for:
- iPhone: 20x20@2x, 20x20@3x, 29x29@2x, 29x29@3x, 40x40@2x, 40x40@3x, 60x60@2x, 60x60@3x
- App Store (Marketing): 1024x1024@1x
## Run on Simulator
1. Select an iPhone Simulator device (e.g., iPhone 15).
2. Product → Run (Cmd+R).

## Prepare for TestFlight (App Store Connect)
1. Project target → Signing & Capabilities:
   - Team: your developer team
   - Bundle Identifier: unique (must match in App Store Connect)
   - Automatically manage signing: enabled
2. Set a version and build number in the target’s General tab.
3. Product → Archive (use Any iOS Device (arm64) scheme).
4. In the Organizer, Distribute App → App Store Connect → Upload.
5. In App Store Connect, create the app with the same Bundle ID and complete metadata. Enable TestFlight testing.

## Prepare Ad Hoc / Enterprise IPA (optional)
1. Product → Archive → Distribute App → Ad Hoc or Enterprise.
2. Select the appropriate signing certificate and provisioning profile.
3. Export the `.ipa` and share to testers (install via Apple Configurator or MDM).

## Notes
- Filters are combined as follows:
  - Type and Phytotoxicity: match any selected values (if any selected)
  - Application Timing: must overlap at least one selected timing (if any selected)
  - Weeds: herbicide must control all selected weeds
- The current data model treats Timing and Weeds independently. If you need timing-specific weed efficacy, consider a structured model per timing with its own weed list.

## Requirements
- macOS with Xcode 15+ recommended
- Apple Developer Account for signing and distribution

If you’d like, I can generate an Xcode project in this repo with a pre-wired target—just provide your desired Bundle ID and (optionally) display name and I’ll scaffold it for you.
