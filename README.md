# Classic Calendar
A starter native SwiftUI + WidgetKit medium widget inspired by the iOS 14 Calendar layout.

## iPad workflow
1. Create a **public** GitHub repository named `ClassicCalendar`.
2. Upload all files in this folder, including `.github/workflows/build.yml` (preserve paths).
3. In GitHub Actions, run `Build unsigned iOS app`.
4. Download `ClassicCalendar-unsigned` artifact; extract the ZIP to find the unsigned IPA.

## Important: signing and installation
The IPA is **unsigned and cannot install directly**. The main app and widget extension both need appropriate provisioning, signing, and App Group entitlements. Free Personal Team provisioning is managed through Xcode and expires after seven days. An iPad-only installation of this App Group-based WidgetKit project is not guaranteed using ordinary sideloaders. A paid Apple Developer account with TestFlight or temporary access to Xcode on a Mac is more reliable.

## Functionality limitation
The host app must be opened and `Sync Calendar` tapped to refresh the stored event snapshot. The widget timeline itself does not fetch EventKit data; iOS may defer widget refreshes. This is a functional starter, not yet a continuously auto-syncing widget or a pixel-perfect match.

## IDs
Before signing, replace `com.example.classiccalendar` and `group.com.example.classiccalendar` consistently with your own identifiers and configure matching App Group capabilities in the signing profiles for both targets.
