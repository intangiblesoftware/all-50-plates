# All 50 Plates — Refactoring Plan v3

**Minimum deployment target: iOS 17**
**Drafted: April 2026 — Revised: April 2026 (v3)**
**Review history: refactoring_review.md → v2 → refactoring_review_v2.md → v3**

---

## Responses to v2 Review

All seven items accepted. No pushback.

**`SettingsView` dead code — ACCEPTED.** Verified: `SettingsView` is never instantiated outside its own preview. It also references three non-existent color names (`Color("ButtonColor")`, `Color("MainText")`, `Color("OldAccentColor")`). Delete in Phase 2.

**Duplicate `CompanyView` — ACCEPTED.** `SettingsView.swift` defines `CompanyView(title:imageName:companyName:companyLink:)`, `AboutView.swift` defines `CompanyView(imageName:companyName:companyLink:linkText:)` — two different types, same name, same module. No compile error today only because `SettingsView.swift` is dead code. Deleting `SettingsView.swift` in Phase 2 resolves this automatically.

**Phase 1 table used `PlatesViewModel` before Phase 2 rename — ACCEPTED.** Fixed below: Phase 1 table uses `AppModel` throughout, with a note that Phase 2 renames it.

**`FilterSelectorView` binding type mismatch — ACCEPTED.** `$model.filterState` is `Binding<ListFilterState>`; `SegmentsView.selectedIndex` expects `Binding<Int>`. These are not interchangeable. The custom `Binding<Int>` bridge is still required after Phase 1. Plan now specifies the correct code. Noted as a candidate for improvement in Phase 2 (update `SegmentsView` to accept a typed enum binding directly).

**`AboutView` dismissal not specified — ACCEPTED.** Use `@Environment(\.dismiss)`. Added explicitly to Phase 1.

**`DataStore` init subscript `[0]` — ACCEPTED.** Use `.first ?? temporaryDirectory`. Updated in Phase 3 snippet.

**iPad grid needs vertical layout — ACCEPTED.** A horizontal list row won't work as a grid card. Added as explicit design question for Eric in Phase 4.

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
- `saveState()` only triggered on app background — crash mid-session loses data
- Legacy `listIsFiltered` UserDefaults migration is dead weight
- `LicensePlateView` holds an `@EnvironmentObject` it never uses
- `LicensePlateViewModel.swift` is entirely unreferenced dead code

### Changes

**Adopt `@Observable` (iOS 17+)**

Replace `ObservableObject` + `@Published` with the `@Observable` macro. Drop `import Combine`. Any stored property change automatically triggers view updates, including through computed properties.

**Full injection mechanism migration — every affected file**

`@Observable` uses different injection than `ObservableObject`. Note: the type is still named `AppModel` during Phase 1 — Phase 2 does the rename.

| Location | Before | After |
|---|---|---|
| `All_50_PlatesApp.swift` | `@StateObject var appModel = AppModel(...)` | `@State var appModel = AppModel(...)` |
| `All_50_PlatesApp.swift` | `.environmentObject(appModel)` | `.environment(appModel)` |
| All view files | `@EnvironmentObject var model: AppModel` | `@Environment(AppModel.self) var model` |
| `FilterSelectorView` | `@EnvironmentObject var model: AppModel` | `@Bindable var model: AppModel` |
| `AboutView` | `model.aboutIsShowing = false` | `@Environment(\.dismiss) var dismiss` then `dismiss()` |

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

**`FilterSelectorView` binding — type bridge still required**

`$model.filterState` is `Binding<ListFilterState>`; `SegmentsView.selectedIndex` expects `Binding<Int>`. The custom bridge binding is unchanged:

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

The only change is the property wrapper on `model`: `@EnvironmentObject` → `@Bindable`. Consider updating `SegmentsView` in Phase 2 to accept a typed `Binding<ListFilterState>` directly, eliminating this bridge.

**Fix `date` handling — `decodeIfPresent`**

Change `LicensePlateModel`'s decoder:
```swift
// Before
date = try values.decode(String.self, forKey: .date)

// After
date = try values.decodeIfPresent(String.self, forKey: .date)
```

Unfound plates store `date = nil`. Found plates store an ISO8601 string. Seed data plates with `date = ""` decode safely: `decodeIfPresent` returns `""`, `updateDateFormat()` does nothing with it, and `dateDisplay` returns `""` — no change in behavior.

**Fix `tapped()` mutation**

```swift
func tapped(_ plate: LicensePlateModel) {
    guard let index = allPlates.firstIndex(where: { $0.id == plate.id }) else { return }
    allPlates[index].found.toggle()
    allPlates[index].date = allPlates[index].found ? Date().ISO8601Format() : nil
    saveState()
}
```

**Save on every mutation**

Call `saveState()` from `tapped()` and `reset()`. Keep `scenePhase` background hook as a safety net only.

**Move `aboutIsShowing` to the view layer**

`LicensePlateListView` owns `@State var aboutIsShowing = false` and passes a binding or action to `AppHeaderView`. `AboutView` dismisses itself with `@Environment(\.dismiss)` — no binding into the parent needed.

**Remove legacy migration**

Delete the `listIsFiltered` UserDefaults read in `init`.

**Delete dead code**

- Remove unused `@EnvironmentObject var model: AppModel` from `LicensePlateView`
- Delete `LicensePlate/LicensePlateViewModel.swift` entirely (unreferenced; contains an older duplicate of date migration logic)

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

**Standalone commit only** — automated find-replace across all files, nothing else in that commit. Keeps the rename trivially reviewable and easily reverted. Do not mix structural changes into the same commit.

### Delete dead code

- Delete `SettingsView.swift` — never instantiated outside its own preview; references three non-existent color names; contains a conflicting `CompanyView` definition. Deleting it also resolves the duplicate `CompanyView` collision.

### View coupling audit

- `FilterSelectorView` — consider updating `SegmentsView` to accept `Binding<ListFilterState>` directly, removing the `Int` bridge. Eric's component; needs his involvement.
- `GameProgressView` — reads computed properties from the ViewModel. Acceptable coupling.
- `AppHeaderView` — no longer touches the ViewModel for sheet presentation (fixed in Phase 1).

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

Refactor `DataStore` to accept a base `URL` before writing tests. Tests pass a temp directory; the default is the Documents directory:

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
- `reset()` sets all plates to `found = false`, `date = nil`
- `filterState` change persists to UserDefaults

**`DataStoreTests`**
- Encode → decode round-trip produces identical plate array
- `fetch()` returns bundle data when no saved file exists
- `fetch()` returns saved file data when saved file exists
- `reset()` removes the saved file
- All tests use injected temp directory

**`MockDataStore`**
Keep in main target under `#if DEBUG`. Include legacy date format fixture (`"MMMM d, yyyy"`) intentionally — documents the migration requirement.

---

## Phase 4 — Adaptive Layout: iPhone + iPad

### Decision gate: `AppHeaderView` fate
**Must be resolved with Jim + Eric before Phase 4 begins.**

`LicensePlateListView` uses a custom `AppHeaderView`. Adding `NavigationStack` creates a duplicate nav bar. Options:

1. Hide native nav bar, keep custom header → Liquid Glass doesn't apply automatically in Phase 5
2. **Migrate to native nav bar, remove `AppHeaderView`** ← recommended

Rationale for Option 2: `AppHeaderView` is a hand-built reimplementation of what `NavigationStack` gives natively. "All 50 Plates" title maps to `.navigationTitle`. The gear button maps to a `.toolbar` trailing item. Custom Futura title font can be applied via `UINavigationBarAppearance` if needed. Result: simpler layout, one fewer custom component, Liquid Glass works automatically.

If the answer is "keep the custom header," Phase 5 must plan a manual glass treatment for `AppHeaderView` instead of relying on automatic adoption.

### iPhone (refined baseline)

- Wrap root in `NavigationStack`
- App title + gear button move to `.navigationTitle` / `.toolbar` (pending decision gate)
- Plate row image width: proportional (`geometry.size.width * 0.35`) not hardcoded `125pt`
- Hardcoded `72pt` header/progress heights replaced with dynamic sizing
- Verify landscape iPhone renders correctly

### iPad

- `@Environment(\.horizontalSizeClass)` drives layout branching
- **Regular width (iPad)**: `NavigationSplitView`
  - Sidebar: game progress stats, filter controls, About/Reset
  - Detail: plate list (portrait) or plate grid (landscape)
- **Compact width (iPhone)**: vertical stack, refined

**iPad grid layout — design question for Eric**

The current `LicensePlateView` is a horizontal row: image left, date center, checkmark right. In a `LazyVGrid`, cells are roughly square — this layout doesn't adapt. The grid card likely needs a vertical arrangement: plate image on top, state name below, checkmark overlaid or alongside. This is a design decision that must be made before implementing the grid — not an implementation detail.

```swift
// Grid definition
LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) { ... }
```

Implement separate `PlateListRow` and `PlateGridCard` view components — same data model, different layouts. v2 said "single `LicensePlateView` works in both contexts" — that was wrong and is corrected here.

- Review `feature/ipad` stash (`stash@{0}`) for salvageable WIP before starting

---

## Phase 5 — Design: Liquid Glass + Light/Dark Mode

### Decision gate: Dynamic Type
**Must be resolved before Phase 5 begins.**

Futura does not scale with Dynamic Type. Current `FontUtils.swift` uses fixed point sizes. True Dynamic Type support requires `UIFontMetrics` scaling — real engineering work, not a quick check.

- **Option A**: Implement `UIFontMetrics` scaling for all custom font sizes
- **Option B**: Explicitly accept fixed-size fonts; add a comment to `FontUtils.swift` documenting this as intentional

Either is valid. Needs Jim's call.

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

For users not on iOS 26, a polished redesign using SwiftUI `Material`:
- Header/nav area: `.ultraThickMaterial` or native nav bar
- Filter bar: `.regularMaterial` background with custom selection highlight
- Plate cards: `.thinMaterial` or solid `AppCardBackground` with refined border
- Progress bar: clean rounded rect, no `scaleEffect` hack

### iOS 26+: Liquid Glass

iOS 26 shipped fall 2025; these are stable APIs. Wrap in `if #available(iOS 26, *) { } else { }`.

- **Navigation bar**: `NavigationStack` adopts Liquid Glass automatically. No code needed.
- **Filter bar**: Evaluate native `Picker(.segmented)` first — it may adopt Liquid Glass automatically, requiring no changes to `SegmentsView`. If not, wrap in `GlassEffectContainer` and pass `backgroundColor: .clear` to prevent `SegmentsView`'s internal fill from painting over the glass. **Either path requires Eric's review.**
- **Progress area**: Float above list with `.glassEffect()` background
- **Reset button in AboutView**: `.buttonStyle(.glassProminent)`
- **Plate cards**: Do NOT apply glass to list/grid content — Apple reserves glass for the navigation layer

**Constraint**: `.glassEffect()` cannot sample other glass. Use `GlassEffectContainer` for adjacent glass elements.

---

## Phase 6 — License Plate Images
*Deferred pending asset delivery.*

### SVG editing
SVGs are XML — editable directly. Colors, fills, strokes, gradients can be added or modified. Once the pattern is established for one plate it can be applied across all 51 consistently.

### Approach: single SVG + SwiftUI state
One SVG per plate. Found/unfound appearance handled in SwiftUI. Simpler to maintain than 102 assets.

### Process
1. Jim provides the new SVG files
2. Review structure (paths, viewBox, existing fills)
3. Apply any color corrections
4. Drop into `Assets.xcassets/Plates/` — image names (2-letter state code) unchanged, no code changes required
5. Verify rendering in both list row and grid card contexts (Phase 4 components)

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

4. **`SegmentsView` for Liquid Glass** — Either native `Picker` evaluation or modifying `SegmentsView`. Eric's component; needs his involvement.

5. **iPad grid card layout** — Horizontal list row won't work in a grid. Vertical card layout (image top, name below) needs Eric's design direction before Phase 4 grid work begins.

**Open items**:

6. **New plate image files** — Where are they? What format?

7. **Washington DC** — Included as entry 51. Keep or remove?

8. **`feature/swipe-to-find`** — Abandoned due to UX issues. Revisit post-Phase 4, or permanently close?

9. **`feature/convert-to-classes`** — `@Observable` requires classes. This branch's intent is satisfied by Phase 1. Close it.

10. **App Store release timing** — Target date? Helps prioritize which phases are blocking.

11. **Eric's overall availability** — Phases 4 and 5 have significant design impact on his work. Confirm he's in the loop before those phases begin.
