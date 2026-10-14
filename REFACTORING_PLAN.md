# All 50 Plates — Refactoring Plan

**Minimum deployment target: iOS 17**
**Date drafted: April 2026**

---

## Goals

- Clean MVVM architecture with proper separation of concerns
- Adaptive layout supporting both iPhone and iPad
- Full light/dark mode support with Liquid Glass design (iOS 26+, with polished fallback for iOS 17–25)
- Meaningful test coverage
- New license plate image assets
- No external dependencies (maintain current approach)

---

## Phase 1 — AppModel Refactor
*Foundation. Everything else builds on this. No visible changes to the user.*

### Problems being fixed
- `displayedPlates`, `totalPlates`, `numberFound`, `numberRemaining` are derived state stored as manually-synced `@Published` vars. Every mutation site must call both `refreshDisplayedPlates()` and `updateCounts()` — easy to miss.
- `aboutIsShowing: Bool` is UI presentation state living inside the model.
- `tapped(plate:)` mutates via `removeAll` + `append` — loses position, creates a whole new struct to flip one bool.
- `saveState()` is only triggered on app background via `scenePhase`. A crash mid-session loses data.
- Legacy `listIsFiltered` UserDefaults migration code is dead weight for any current user.
- `LicensePlateView` holds an `@EnvironmentObject var model: AppModel` it never uses.

### Changes

**Adopt `@Observable` (iOS 17+)**
Replace `ObservableObject` + `@Published` with the `@Observable` macro. With `@Observable`, any stored property change triggers view updates automatically — including through computed properties. Remove the `Combine` import.

**Convert derived state to computed properties**
```swift
var displayedPlates: [LicensePlateModel] { ... }  // computed from allPlates + filterState
var totalPlates: Int { allPlates.count }
var numberFound: Int { allPlates.filter(\.found).count }
var numberRemaining: Int { allPlates.filter { !$0.found }.count }
```
`refreshDisplayedPlates()` and `updateCounts()` are deleted entirely.

**Move `aboutIsShowing` to the view layer**
`LicensePlateListView` owns a `@State var aboutIsShowing = false`. `AppHeaderView` receives an action closure or binding rather than reaching into the model.

**Fix `tapped(plate:)` mutation**
```swift
func tapped(_ plate: LicensePlateModel) {
    guard let index = allPlates.firstIndex(where: { $0.id == plate.id }) else { return }
    allPlates[index].found.toggle()
    allPlates[index].date = allPlates[index].found ? Date().ISO8601Format() : nil
    saveState()
}
```

**Save on every mutation**
Call `saveState()` inside `tapped()` and `reset()`. Keep the `scenePhase` background hook as a safety net only.

**Remove legacy migration**
Delete the `listIsFiltered` UserDefaults read in `init`. Any user still carrying that key will silently default to `.allPlates` — acceptable.

**Fix `LicensePlateView`**
Remove the unused `@EnvironmentObject var model: AppModel`.

### Resulting file changes
- `AppModel.swift` — significant simplification (~50% smaller)
- `LicensePlateListView.swift` — add local `@State var aboutIsShowing`
- `AppHeaderView.swift` — remove model dependency for sheet presentation
- `LicensePlateView.swift` — remove unused environment object
- Remove `import Combine` from AppModel

---

## Phase 2 — MVVM Structure
*Cleaner boundaries between model, view model, and view. Still no visible user changes.*

### Changes

**Rename `AppModel` → `PlatesViewModel`**
The name should reflect what it is. Update all references.

**Audit view-to-ViewModel coupling**
Each view should only access ViewModel properties relevant to it. Current violations:
- `AppHeaderView` sets `aboutIsShowing` on the model (fixed in Phase 1)
- `FilterSelectorView` reaches into the ViewModel — should take `filterState` as a `@Bindable` binding
- `GameProgressView` reads 4 model properties — acceptable, but should use the ViewModel minimally

**Evaluate `LicensePlateViewModel`**
Currently lives in `/Views/LicensePlate/LicensePlateViewModel.swift`. With `@Observable` and `LicensePlateModel` already carrying display logic (`dateDisplay`), this may be redundant. Evaluate and either delete or give it a clear purpose.

**File/folder cleanup**
- Rename `AppModel.swift` → `PlatesViewModel.swift`
- Move `EmptyListView` out of `LicensePlateListView.swift` into its own file
- Move `MyButtonStyle` out of `LicensePlateListView.swift` into `Components/`
- Consolidate or delete `SettingsView.swift` — `AboutView` covers this ground already

### Resulting structure
```
Models/
    LicensePlateModel.swift
    ListFilterState.swift
ViewModels/
    PlatesViewModel.swift
Repositories/
    DataStore.swift
    MockDataStore.swift
Views/
    LicensePlateListView.swift
    LicensePlateView.swift
    AppHeaderView.swift
    GameProgressView.swift
    FilterSelectorView.swift
    AboutView.swift
    EmptyListView.swift
    DeveloperToolsView.swift   (DEBUG only)
Components/
    SegmentsView.swift
    ViewBackground.swift
    VScrollView.swift
    PlateButtonStyle.swift     (renamed from MyButtonStyle)
Utilities/
    ColorUtils.swift
    FontUtils.swift
    HapticUtils.swift
App/
    All_50_PlatesApp.swift
    Constants.swift
    ISFont.swift
```

---

## Phase 3 — Testing
*Zero tests currently. This phase adds a meaningful safety net before the UI work begins.*

### Add `All 50 PlatesTests` XCTest target

**`LicensePlateModelTests`**
- Old date format (`"MMMM d, yyyy"`) converts correctly to ISO8601 on decode
- ISO8601 string passes through unchanged
- Empty/nil date produces empty `dateDisplay`
- `id` is the 2-letter plate code
- `found` toggles correctly via direct mutation

**`PlatesViewModelTests`** (formerly AppModelTests)
- `tapped()` sets `found = true` and a non-empty date on first tap
- `tapped()` sets `found = false` and clears date on second tap
- `reset()` sets all plates to `found = false`
- `numberFound` + `numberRemaining` always sum to `totalPlates`
- `displayedPlates` returns correct subset for each `filterState`
- `filterState` change persists to UserDefaults

**`DataStoreTests`**
- Encode → decode round-trip produces identical plate array
- `fetch()` returns bundle data when no saved file exists
- `fetch()` returns saved file data when it exists
- `reset()` deletes the saved file

**`MockDataStore` cleanup**
Keep `MockDataStore` as a test double conforming to `LicensePlateStoreProtocol`. Ensure it includes the legacy date format fixture intentionally (documents the migration requirement).

---

## Phase 4 — Adaptive Layout: iPhone + iPad

### iPhone (refined baseline)
- Wrap root view in `NavigationStack` — sets up Phase 5 Liquid Glass nav bar adoption automatically
- Plate row image width switches from hardcoded `125pt` to proportional (`geometry.size.width * 0.35` or similar)
- Hardcoded `72pt` header/progress heights become adaptive using `ViewThatFits` or dynamic sizing
- Landscape iPhone: list adjusts gracefully (currently untested)

### iPad
- Use `@Environment(\.horizontalSizeClass)` to branch layout
- **Regular width (iPad)**: `NavigationSplitView` with:
  - Sidebar: app title, game progress stats, filter controls, About/Reset button
  - Detail: plate list (single column) or grid (two columns in landscape)
- **Compact width (iPhone)**: current vertical stack layout, refined
- Plate grid on iPad uses `LazyVGrid` with adaptive columns:
  ```swift
  LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) { ... }
  ```
- Sidebar width: system default (~320pt on iPad)
- Review `feature/ipad` branch — has stashed WIP (`stash@{0}`) worth examining before starting

### Shared adaptive components
- `PlateGridItem` / `PlateListItem` — same data, two presentations
- Progress stats: horizontal on iPad sidebar, compact bar on iPhone

---

## Phase 5 — Design: Liquid Glass + Light/Dark Mode

### Light/Dark mode (all iOS versions)

Every named color in `Assets.xcassets` currently has no light/dark variants. Add both:

| Color name | Light appearance | Dark appearance |
|---|---|---|
| AppBackground | Light gray/white | Near-black |
| AppCardBackground | White | Dark gray |
| AppDark | Dark navy/charcoal | Slightly lighter dark |
| AppLight | White | Off-white |
| AppText | Near-black | Near-white |
| AppSubtext | Medium gray | Light gray |
| AppButtonText | White | White |
| AppGray | Medium gray | Dark gray |

Exact values to be defined with Eric / design review.

### iOS 17–25: Material fallback design
For users not on iOS 26, deliver a polished redesign using SwiftUI `Material`:
- Header bar: `.ultraThickMaterial` background
- Filter bar: `.regularMaterial` background with custom highlight
- Plate cards: `.thinMaterial` or solid `AppCardBackground` with refined border
- Progress bar: clean rounded rect, no scaleEffect hack

### iOS 26+: Liquid Glass
Wrap features in `if #available(iOS 26, *) { } else { }` or use `@available` on view variants.

- **Navigation bar**: `NavigationStack` adopts Liquid Glass automatically on iOS 26. No code needed.
- **Filter bar**: Wrap `SegmentsView` in `GlassEffectContainer`. Selected segment gets `.glassEffect(.regular)`.
- **Progress overlay**: Float above list content with `.glassEffect()` background rather than fixed opaque block.
- **About/Reset button**: `.buttonStyle(.glassProminent)`.
- **Plate cards**: Do NOT apply glass to list content — Apple's guidelines explicitly reserve glass for the navigation layer. Cards use material backgrounds.

### Key constraint
`.glassEffect()` cannot sample other glass. Use `GlassEffectContainer` to group any adjacent glass elements (e.g. filter bar + progress area if they're near each other).

### Typography review
Futura is thematically appropriate for a license-plate app. Keep it. Verify all weights used (`Futura-CondensedExtraBold`, `Futura-Bold`, `Futura-Medium`) are embedded correctly and review sizing for Dynamic Type compatibility.

---

## Phase 6 — License Plate Images

### SVG editing
SVG files are XML text — they can be edited directly to add fills, strokes, gradients, and color adjustments. Once we establish the pattern for one plate, changes can be applied consistently across all 51 files.

**Questions to resolve before starting:**
1. Where are the new SVG files? (User to provide path)
2. What color treatment for found vs. unfound state? Options:
   - **Current approach**: single SVG per plate, opacity reduced in SwiftUI for found state
   - **New approach**: two SVG variants per plate (full color / desaturated), or use SwiftUI rendering modes
   - **Preferred**: keep single SVG, handle found/unfound state in SwiftUI for flexibility

### Asset replacement process
1. Review new SVG structure (paths, viewBox, existing fills)
2. Apply any color corrections needed
3. Drop into `Assets.xcassets/Plates/` — image names (state abbreviation, e.g. `CA`) stay the same, no code changes required
4. Verify rendering at all required sizes (list row, any future grid/detail view)

---

## Branch Strategy

| Phase | Branch | Depends on |
|---|---|---|
| 1 — AppModel refactor | `refactor/app-model` | — |
| 2 — MVVM structure | `refactor/mvvm` | Phase 1 |
| 3 — Tests | `refactor/testing` | Phase 2 |
| 4 — Adaptive layout | `feature/adaptive-layout` | Phase 2 |
| 5 — Liquid Glass + design | `feature/liquid-glass` | Phase 4 |
| 6 — New plate images | `feature/new-plate-images` | — (independent) |

All branches cut from `develop`. Each phase merges to `develop` before the next begins. Phases 1–3 are pure refactoring with no visible user-facing changes.

---

## Open Questions

1. **Eric Ziegler involvement**: Phases 4 and 5 have significant design impact. Is Eric reviewing / contributing to the new design direction?
2. **New plate images**: Where are the files? What format are they in?
3. **Washington DC**: Currently included as entry 51. Intentional? Keep or remove?
4. **`feature/swipe-to-find` branch**: Swipe gesture was abandoned due to UX issues with filtered lists. Worth revisiting after adaptive layout is in place, or permanently shelve?
5. **`feature/convert-to-classes` branch**: With `@Observable`, class-based models are the right call anyway. This branch's intent is satisfied by Phase 1 — close it.
6. **App Store release timing**: Is there a target for when this should ship? Helps prioritize which phases are blocking.
