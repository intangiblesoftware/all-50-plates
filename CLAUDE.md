# All 50 Plates — Claude Code Reference

## Project Overview

**All 50 Plates** is an iOS/iPadOS app built with Swift and SwiftUI. Users track US state license plates they spot during road trips, with the goal of finding all 50 states.

- **Language**: Swift
- **Framework**: SwiftUI
- **Platforms**: iPhone, iPad (iPad support planned — see refactoring plan)
- **Version**: 1.3.x
- **Minimum deployment target**: iOS 17 (decided)
- **Team**: Jim Dabrowski (developer/creator), Eric Ziegler (designer, `eziegler/` branches)

---

## Status: Major Refactor Planned

A comprehensive refactoring plan has been drafted, reviewed (four rounds), and finalised. See **`REFACTORING_PLAN_FINAL.md`** in the project root — that is the authoritative reference. Do not start work without reading it.

**Next step**: Begin Phase 1 on branch `refactor/app-model`.

### Phase summary

| Phase | Branch | Status |
|---|---|---|
| 1 — AppModel refactor (`@Observable`, fix bugs) | `refactor/app-model` | **Ready to start** |
| 2 — MVVM structure (rename, dead code, folder cleanup) | `refactor/mvvm` | Awaits Phase 1 |
| 3 — Tests (XCTest target, DataStore refactor) | `refactor/testing` | Awaits Phase 2 |
| 4 — Adaptive layout (iPhone + iPad, NavigationStack) | `feature/adaptive-layout` | Awaits Phase 2 + decision gate |
| 5 — Liquid Glass + Light/Dark design | `feature/liquid-glass` | Awaits Phase 4 + decision gate |
| 6 — New license plate images (SVG) | `feature/new-plate-images` | Awaits asset delivery from Jim |

### Decision gates blocking Phases 4–5

These must be resolved with Jim and Eric before those phases begin:

1. **`AppHeaderView` fate**: Replace with native `NavigationStack` nav bar (recommended — enables automatic Liquid Glass), or keep custom header and handle glass manually? Jim + Eric sign-off needed.
2. **Dynamic Type**: Implement `UIFontMetrics` scaling for Futura, or explicitly accept fixed-size fonts? Jim's call.
3. **Eric Ziegler's involvement**: Three things need him before Phases 4–5 — `AppHeaderView` decision, Light/Dark color values for all named colors, and `SegmentsView` updates (typed binding + Liquid Glass treatment).

---

## Current Project Structure

```
All 50 Plates/
├── App/
│   ├── All_50_PlatesApp.swift      # Entry point; injects AppModel as @StateObject
│   ├── Constants.swift             # UserDefaults keys + resource names
│   └── ISFont.swift                # Custom font name constants (Futura, Georgia)
├── Components/
│   ├── SegmentsView.swift          # Custom segmented control (Eric's component)
│   ├── ViewBackground.swift        # Reusable full-screen background wrapper
│   └── VScrollView.swift           # ScrollView + VStack convenience wrapper
├── Models/
│   ├── AppModel.swift              # Central ObservableObject — TO BE REFACTORED
│   ├── LicensePlateModel.swift     # Codable struct for a single plate
│   └── ListFilterState.swift       # Enum: .allPlates / .found / .notFound
├── Repositories/
│   ├── DataStore.swift             # Persistence: reads/writes plist to Documents dir
│   └── MockDataStore.swift         # Stub for previews; edge-case fixture data intentional
├── Utilities/
│   ├── ColorUtils.swift            # Color extensions (named colors)
│   ├── FontUtils.swift             # Font extensions (fixed sizes — Dynamic Type TBD)
│   └── HapticUtils.swift           # AVFoundation haptic helpers
├── Views/
│   ├── LicensePlateListView.swift  # Main screen
│   ├── LicensePlateView.swift      # Single plate row (has unused @EnvironmentObject — Phase 1 fix)
│   ├── AppHeaderView.swift         # Top title bar (fate TBD — see decision gate)
│   ├── GameProgressView.swift      # Progress bar + counts
│   ├── FilterSelectorView.swift    # Filter tab row
│   ├── AboutView.swift             # Settings / About screen
│   ├── SettingsView.swift          # DEAD CODE — delete in Phase 2
│   ├── DeveloperToolsView.swift    # DEBUG-only
│   └── LicensePlate/
│       └── LicensePlateViewModel.swift  # DEAD CODE — delete in Phase 1
└── Resources/
    ├── plates.plist                # Seed data: 51 entries (50 states + DC)
    ├── Assets.xcassets/            # 50 state plate images (SVG) + app icon
    └── Colors.xcassets/            # Named colors — NO light/dark variants yet (Phase 5)
```

---

## Architecture (Current — pre-refactor)

- `AppModel` (`ObservableObject`) is the primary ViewModel. Views receive it via `@EnvironmentObject`.
- `DataStore` / `MockDataStore` implement `LicensePlateStoreProtocol`.

**After Phase 1**, the architecture becomes:
- `AppModel` adopts `@Observable` (iOS 17+). `@StateObject`/`@EnvironmentObject` replaced with `@State`/`@Environment`.
- Derived state (`displayedPlates`, counts) becomes computed properties — no more manual sync.
- `AppModel` renamed to `PlatesViewModel` in Phase 2 (standalone commit).

---

## Known Bugs (to be fixed in Phase 1)

- **`LicensePlateModel.encode(to:)`** uses `container.encode(date, forKey: .date)` — plist format cannot encode `Optional.none`, so saving any unfound plate after Phase 1's `nil`-date change would silently fail. Fix: `encodeIfPresent`.
- **`reset()` re-fetches from store** — broken with `MockDataStore` (no-op reset, always returns fixture data). Fix: clear state in-place, store only deletes the file.
- **`FilterSelectorView`** currently uses `@EnvironmentObject` — Phase 1 changes to `@Environment(AppModel.self)`, not `@Bindable` (which would require parameter injection, not environment injection).

---

## Data Model: `LicensePlateModel`

```swift
struct LicensePlateModel: Codable, Identifiable {
    var state: String      // Full state name, e.g. "California"
    var plate: String      // 2-letter code, e.g. "CA" — also the image asset name
    var found: Bool
    var date: String?      // ISO8601 string when found, nil when not found
                           // (currently "" in seed data — handled gracefully)
}
```

Date migration: legacy `"MMMM d, yyyy"` format is converted to ISO8601 in `updateDateFormat()`. `MockDataStore` includes this format intentionally.

---

## Git Branches

| Branch | Status | Notes |
|--------|--------|-------|
| `develop` | **active/main** | Default branch; start all new branches from here |
| `main` | stable | Mirrors App Store releases |
| `feature/ipad` | WIP | Has stash (`stash@{0}`) — review before starting Phase 4 |
| `feature/swipe-to-find` | stalled | UX issues; revisit post-Phase 4 or close |
| `feature/convert-to-classes` | obsolete | `@Observable` (Phase 1) satisfies the intent — close it |
| `origin/feature/mvvm` | remote only | Earlier MVVM attempt — reference only |

**Stashes**: `stash@{0}` (iPad WIP), `stash@{1}`, `stash@{2}` (temp develop work), `stash@{3}` (bad filter attempt)

---

## Key Conventions

- **No external dependencies** — pure Swift/SwiftUI + AVFoundation only
- **Custom fonts**: Futura (multiple weights) and Georgia; constants in `ISFont.swift` and `FontUtils.swift`
- **Named colors**: Always use asset catalog names via `ColorUtils.swift` — never hardcode colors
- **Haptics**: Use `HapticUtils`, not AVFoundation directly
- **DEBUG code**: `DeveloperToolsView` and (after Phase 2) `MockDataStore` are `#if DEBUG` — keep it that way
- **Persistence**: plist format, Documents directory. No JSON, no CoreData.
- **Eric's components**: `SegmentsView` is Eric's — coordinate with him before changing it

---

## Build & Run

Open `All 50 Plates.xcodeproj` in Xcode. No package manager, no Podfile, no SPM dependencies. Build and run directly on device or simulator.
