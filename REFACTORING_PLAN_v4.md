# All 50 Plates — Refactoring Plan v4

**Minimum deployment target: iOS 17**
**Drafted: April 2026 — Revised: April 2026 (v4)**
**Review history: review → v2 → review_v2 → v3 → review_v3 → v4**

---

## Responses to v3 Review

Three items, all accepted. No pushback.

**`reset()` design flaw — ACCEPTED.**
Reviewer is correct. `MockDataStore.reset()` is a no-op and `MockDataStore.fetch()` always returns its fixed data including three `found: true` plates, so the test spec's assertion "all plates set to `found = false`" would fail against any mock-backed ViewModel. The same problem exists with real `DataStore`: re-fetching after file deletion returns bundle seed data with `date = ""`, not `nil`. Root cause: `reset()` was delegating responsibility for clearing in-memory state to `fetch()`, which is wrong. Fix: ViewModel clears state in-place, store only handles file deletion. Implementation updated in Phase 1 below.

**`MockDataStore` needs `#if DEBUG` — ACCEPTED.**
Currently not wrapped. Added explicitly to Phase 2's change list alongside `SettingsView` deletion.

**`SegmentsView` update — "consider" → Phase 2 task — ACCEPTED.**
Promoted from optional consideration to a concrete Phase 2 task (pending Eric's involvement). Removes the `Binding<Int>` bridge before the test phase begins.

---

## Goals

- Clean MVVM architecture with proper separation of concerns
- Adaptive layout supporting both iPhone and iPad
- Full light/dark mode with Liquid Glass design (iOS 26+, polished material fallback for iOS 17–25)
- Meaningful test coverage
- New license plate image assets
- No external dependencies

---

## Phase 1 — AppModel Refactor
*Foundation. No visible changes to the user.*

### Problems being fixed

- Derived state stored as manually-synced `@Published` vars — every mutation site calls `refreshDisplayedPlates()` + `updateCounts()` by hand
- `aboutIsShowing: Bool` is UI presentation state inside the model
- `tapped(plate:)` mutates via `removeAll` + `append`
- `reset()` delegates clearing in-memory state to `fetch()` — wrong responsibility
- `saveState()` only triggered on app background — crash mid-session loses data
- Legacy `listIsFiltered` UserDefaults migration is dead weight
- `LicensePlateView` holds an `@EnvironmentObject` it never uses
- `LicensePlateViewModel.swift` is entirely unreferenced dead code

### Changes

**Adopt `@Observable` (iOS 17+)**

Replace `ObservableObject` + `@Published` with the `@Observable` macro. Drop `import Combine`. Any stored property change automatically triggers view updates, including through computed properties.

**Full injection mechanism migration — every affected file**

`@Observable` uses different injection than `ObservableObject`. Note: the type is still named `AppModel` during Phase 1 — Phase 2 does the rename as a standalone commit.

| Location | Before | After |
|---|---|---|
| `All_50_PlatesApp.swift` | `@StateObject var appModel = AppModel(...)` | `@State var appModel = AppModel(...)` |
| `All_50_PlatesApp.swift` | `.environmentObject(appModel)` | `.environment(appModel)` |
| All view files | `@EnvironmentObject var model: AppModel` | `@Environment(AppModel.self) var model` |
| `FilterSelectorView` | `@EnvironmentObject var model: AppModel` | `@Bindable var model: AppModel` |
| `AboutView` | `model.aboutIsShowing = false` | `@Environment(\.dismiss) var dismiss` + `dismiss()` |

Affected view files: `LicensePlateListView`, `AppHeaderView`, `GameProgressView`, `FilterSelectorView`, `AboutView`.

**Convert derived state to computed properties**

```swift
var displayedPlates: [LicensePlateModel] {
    let filtered: [LicensePlateModel]
    switch filterState {
    case .allPlates: filtered = allPlates
    case .found:     filtered = allPlates.filter(\.found)
    case .notFound:  filtered = allPlates.filter { !$0.found }
    }
    return filtered.sorted { $0.state < $1.state }
}

var totalPlates: Int     { allPlates.count }
var numberFound: Int     { allPlates.filter(\.found).count }
var numberRemaining: Int { allPlates.filter { !$0.found }.count }
```

`refreshDisplayedPlates()`, `updateCounts()`, `sortPlates()`, and `countFor(state:)` are deleted entirely.

**`FilterSelectorView` binding — type bridge still required (Phase 2 will fix)**

`$model.filterState` is `Binding<ListFilterState>`; `SegmentsView.selectedIndex` expects `Binding<Int>`. The custom bridge is unchanged in Phase 1:

```swift
SegmentsView(
    [...],
    selectedIndex: Binding<Int>(
        get: { model.filterState.rawValue },
        set: { model.filterState = ListFilterState(rawValue: $0) ?? .allPlates }
    ),
    ...
)
```

The only Phase 1 change here is `@EnvironmentObject` → `@Bindable` on the `model` property. Phase 2 updates `SegmentsView` to accept `Binding<ListFilterState>` directly, eliminating this bridge.

**Fix `date` handling — `decodeIfPresent`**

```swift
// Before
date = try values.decode(String.self, forKey: .date)

// After
date = try values.decodeIfPresent(String.self, forKey: .date)
```

Unfound plates store `date = nil`. Found plates store an ISO8601 string. Seed data plates with `date = ""` decode safely: `decodeIfPresent` returns `""`, `updateDateFormat()` does nothing with it, `dateDisplay` returns `""` — no behavioral change.

**Fix `tapped()` mutation**

```swift
func tapped(_ plate: LicensePlateModel) {
    guard let index = allPlates.firstIndex(where: { $0.id == plate.id }) else { return }
    allPlates[index].found.toggle()
    allPlates[index].date = allPlates[index].found ? Date().ISO8601Format() : nil
    saveState()
}
```

**Fix `reset()` — ViewModel owns state, store owns file deletion**

The previous design called `dataStore.reset()` then `allPlates = dataStore.fetch()`, which meant "reset" was whatever the store's `fetch()` returned — broken with `MockDataStore` (no-op reset, always returns fixture data) and inconsistent with the real store (re-fetch returns seed plist with `date = ""` not `nil`).

```swift
func reset() {
    for i in allPlates.indices {
        allPlates[i].found = false
        allPlates[i].date = nil
    }
    dataStore.reset()   // delete the saved file
    saveState()         // write cleared state to disk
}
```

The ViewModel defines what "reset" means. The store just handles file deletion.

**Save on every mutation**

`saveState()` is called from `tapped()` and `reset()` directly. Keep `scenePhase` background hook as safety net only.

**Move `aboutIsShowing` to the view layer**

`LicensePlateListView` owns `@State var aboutIsShowing = false`. `AboutView` dismisses itself with `@Environment(\.dismiss)` — no model reference needed for dismissal.

**Remove legacy migration**

Delete the `listIsFiltered` UserDefaults read in `init`.

**Delete dead code**

- Remove unused `@EnvironmentObject var model: AppModel` from `LicensePlateView`
- Delete `LicensePlate/LicensePlateViewModel.swift` entirely (unreferenced; contains older duplicate date migration logic)

### Files changed in Phase 1

- `AppModel.swift` — substantial simplification
- `All_50_PlatesApp.swift`
- `LicensePlateListView.swift`
- `LicensePlateView.swift`
- `AppHeaderView.swift`
- `GameProgressView.swift`
- `FilterSelectorView.swift`
- `AboutView.swift`
- `LicensePlateModel.swift` (decoder fix)
- Delete: `LicensePlate/LicensePlateViewModel.swift`

---

## Phase 2 — MVVM Structure
*Cleaner boundaries. Still no visible user changes.*

### Rename `AppModel` → `PlatesViewModel`

**Standalone commit only** — automated find-replace across all files, nothing else in that commit. Trivially reviewable; easily reverted.

### Update `SegmentsView` to accept `Binding<ListFilterState>`

Remove the `Binding<Int>` bridge from `FilterSelectorView`. Update `SegmentsView` to accept the enum type directly. **Eric's component — requires his involvement.** Coordinate with him; this is a small change but it's his code.

### Housekeeping — dead and debug-only code

- **Delete `SettingsView.swift`** — never instantiated outside its own preview; references three non-existent color names (`ButtonColor`, `MainText`, `OldAccentColor`); contains a conflicting `CompanyView` definition. Deleting it resolves the duplicate `CompanyView` name collision automatically.
- **Wrap `MockDataStore` in `#if DEBUG`** — same pattern as `DeveloperToolsView`. Currently unwrapped.

### File/folder cleanup

- Move `EmptyListView` out of `LicensePlateListView.swift` → `Views/EmptyListView.swift`
- Rename and move `MyButtonStyle` → `Components/PlateButtonStyle.swift`
- Leave `AboutListCell` and `CompanyView` inline in `AboutView.swift` — too small to warrant separate files

### Target folder structure

```
Models/
    LicensePlateModel.swift
    ListFilterState.swift
ViewModels/
    PlatesViewModel.swift
Repositories/
    DataStore.swift
    MockDataStore.swift          (#if DEBUG)
Views/
    LicensePlateListView.swift
    LicensePlateView.swift
    AppHeaderView.swift          (may be removed in Phase 4 — see decision gate)
    GameProgressView.swift
    FilterSelectorView.swift
    AboutView.swift
    EmptyListView.swift
    DeveloperToolsView.swift     (#if DEBUG)
Components/
    SegmentsView.swift
    ViewBackground.swift
    VScrollView.swift
    PlateButtonStyle.swift
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
*Zero tests currently. Safety net before UI work begins.*

### Prerequisite: `DataStore` configurable base URL

```swift
class DataStore: LicensePlateStoreProtocol {
    private let baseURL: URL

    init(baseURL: URL = FileManager.default.urls(for: .documentDirectory,
                                                  in: .userDomainMask).first
                        ?? FileManager.default.temporaryDirectory) {
        self.baseURL = baseURL
    }
}
```

Tests create a temp directory in `setUp()` and delete it in `tearDown()`. No real Documents directory touched.

### Add `All 50 PlatesTests` XCTest target

Use `@testable import All_50_Plates`. `MockDataStore` stays in the main target under `#if DEBUG`.

**`LicensePlateModelTests`**
- Old format (`"MMMM d, yyyy"`) converts to ISO8601 on decode
- ISO8601 string passes through unchanged
- Empty string `""` produces empty `dateDisplay`
- `nil` date produces empty `dateDisplay`
- `id` equals the 2-letter plate code

**`PlatesViewModelTests`**
- `tapped()` sets `found = true` and a non-nil date on first call
- `tapped()` sets `found = false` and `date = nil` on second call
- `numberFound` + `numberRemaining` always sum to `totalPlates`
- `displayedPlates` returns correct subset for each `filterState`
- `displayedPlates` is always sorted A→Z regardless of filter
- `reset()` sets all plates to `found = false`, `date = nil` — verified against both `MockDataStore` and a real `DataStore` with temp directory
- `filterState` change persists to UserDefaults

**`DataStoreTests`**
- Encode → decode round-trip produces identical plate array
- `fetch()` returns bundle data when no saved file exists
- `fetch()` returns saved file data when saved file exists
- `reset()` removes the saved file
- All tests use injected temp directory

**`MockDataStore`**
Keep in main target under `#if DEBUG`. The fixture data (including `found: true` plates and legacy date formats) documents deliberate test cases for migration and state handling. Do not "fix" it to be clean data — its edge cases are intentional.

---

## Phase 4 — Adaptive Layout: iPhone + iPad

### Decision gate: `AppHeaderView` fate
**Must be resolved with Jim + Eric before Phase 4 begins.**

`LicensePlateListView` uses a custom `AppHeaderView`. Adding `NavigationStack` creates a duplicate nav bar on top of it. Options:

1. Hide native nav bar, keep custom header → Liquid Glass doesn't apply automatically in Phase 5
2. **Migrate to native nav bar, remove `AppHeaderView`** ← recommended

Rationale for Option 2: `AppHeaderView` is a hand-built reimplementation of what `NavigationStack` provides natively. "All 50 Plates" maps to `.navigationTitle`. The gear icon maps to a `.toolbar` trailing item. Custom Futura title styling can be applied via `UINavigationBarAppearance`. Result: simpler layout, one fewer custom component, automatic Liquid Glass in Phase 5.

If Option 1 is chosen, Phase 5 must plan a manual glass treatment for `AppHeaderView` instead of relying on automatic adoption.

### iPhone (refined baseline)

- Wrap root in `NavigationStack`
- App title + gear button move to `.navigationTitle` / `.toolbar` (pending decision gate)
- Plate row image width: proportional (`geometry.size.width * 0.35`) not hardcoded `125pt`
- Hardcoded `72pt` heights replaced with dynamic sizing
- Verify landscape iPhone renders correctly

### iPad

- `@Environment(\.horizontalSizeClass)` drives layout branching
- **Regular width (iPad)**: `NavigationSplitView`
  - Sidebar: game progress stats, filter controls, About/Reset
  - Detail: plate list (portrait) or plate grid (landscape)
- **Compact width (iPhone)**: vertical stack, refined

**iPad grid layout — design question for Eric (blocks grid implementation)**

The current `LicensePlateView` is a horizontal row: image left, date center, checkmark right. In a `LazyVGrid`, cells are roughly square — this layout doesn't adapt. The grid card needs a vertical arrangement: plate image on top, state name below, checkmark overlaid or alongside. This is a design decision that must be made before implementing the grid.

Implement separate components:
- `PlateListRow` — horizontal layout for iPhone list and iPad list column
- `PlateGridCard` — vertical layout for iPad grid

Same `LicensePlateModel` data, different presentations.

```swift
LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) { ... }
```

- Review `feature/ipad` stash (`stash@{0}`) for salvageable WIP before starting

---

## Phase 5 — Design: Liquid Glass + Light/Dark Mode

### Decision gate: Dynamic Type
**Must be resolved before Phase 5 begins.**

Futura does not scale with Dynamic Type. Current `FontUtils.swift` uses fixed point sizes. True support requires `UIFontMetrics` scaling — real engineering work.

- **Option A**: Implement `UIFontMetrics` scaling for all custom font sizes
- **Option B**: Explicitly accept fixed-size fonts; document as intentional in `FontUtils.swift`

Needs Jim's call.

### Light/Dark mode (all iOS versions)

Every named color in `Assets.xcassets` needs Light and Dark appearance variants. Currently none exist. **Exact values to be defined with Eric.**

| Color | Light | Dark |
|---|---|---|
| AppBackground | Light gray/white | Near-black |
| AppCardBackground | White | Dark gray |
| AppDark | Dark navy/charcoal | Slightly lighter dark |
| AppLight | White | Off-white |
| AppText | Near-black | Near-white |
| AppSubtext | Medium gray | Light gray |
| AppButtonText | White | White |
| AppGray | Medium gray | Dark gray |

### iOS 17–25: Material fallback design

- Header/nav area: `.ultraThickMaterial` or native nav bar
- Filter bar: `.regularMaterial` background with custom selection highlight
- Plate cards: `.thinMaterial` or solid `AppCardBackground` with refined border
- Progress bar: clean rounded rect, no `scaleEffect` hack

### iOS 26+: Liquid Glass

iOS 26 shipped fall 2025; these are stable APIs. Wrap in `if #available(iOS 26, *) { } else { }`.

- **Navigation bar**: `NavigationStack` adopts Liquid Glass automatically. No code needed.
- **Filter bar**: Evaluate native `Picker(.segmented)` first — may adopt Liquid Glass automatically, requiring no `SegmentsView` changes. If not, wrap in `GlassEffectContainer` and pass `backgroundColor: .clear` to prevent `SegmentsView`'s internal fill painting over the glass. **Either path requires Eric's review.**
- **Progress area**: Float above list with `.glassEffect()` background
- **Reset button**: `.buttonStyle(.glassProminent)`
- **Plate cards**: Do NOT apply glass to list/grid content — Apple reserves glass for the navigation layer

**Constraint**: `.glassEffect()` cannot sample other glass. Use `GlassEffectContainer` for adjacent glass elements.

---

## Phase 6 — License Plate Images
*Deferred pending asset delivery.*

### SVG editing
SVGs are XML — editable directly. Colors, fills, strokes, gradients can be added or modified. Pattern established for one plate can be applied across all 51.

### Approach: single SVG + SwiftUI state
One SVG per plate. Found/unfound appearance handled in SwiftUI. Simpler than 102 assets.

### Process
1. Jim provides the new SVG files
2. Review structure (paths, viewBox, existing fills)
3. Apply any color corrections
4. Drop into `Assets.xcassets/Plates/` — image names (2-letter state code) unchanged, no code changes required
5. Verify rendering in `PlateListRow` and `PlateGridCard` contexts

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

All branches cut from `develop`. Each phase merges to `develop` before the next begins.
Phases 1–3: pure refactoring, no visible user-facing changes.

---

## Open Questions / Decision Gates

**Decision gates** (work cannot proceed without these):

1. **`AppHeaderView` fate** — Blocks Phase 4. Replace with native nav bar (recommended), or keep custom? Jim + Eric sign-off required.

2. **Dynamic Type** — Blocks Phase 5. Implement `UIFontMetrics` scaling, or explicitly accept fixed-size fonts? Jim's call.

**Design questions needing Eric**:

3. **Light/Dark color values** — All named colors need Light and Dark variants defined. Eric's domain.

4. **`SegmentsView` updates** — Two touchpoints: (a) Phase 2 typed binding change, (b) Phase 5 Liquid Glass treatment or native `Picker` evaluation. Coordinate both with Eric together.

5. **iPad grid card layout** — Vertical card design needed (`PlateGridCard`). Eric's direction required before Phase 4 grid work begins.

**Open items**:

6. **New plate image files** — Where are they? What format?

7. **Washington DC** — Included as entry 51. Keep or remove?

8. **`feature/swipe-to-find`** — Abandoned due to UX issues. Revisit post-Phase 4, or permanently close?

9. **`feature/convert-to-classes`** — `@Observable` requires classes. Intent satisfied by Phase 1. Close it.

10. **App Store release timing** — Target date? Helps prioritize which phases are blocking.

11. **Eric's overall availability** — Phases 4 and 5 have significant design impact. Confirm he's in the loop before those phases begin.
