# All 50 Plates — Refactoring Plan v2

**Minimum deployment target: iOS 17**
**Original draft: April 2026 — Revised: April 2026**
**Revision incorporates feedback from refactoring_review.md**

---

## Responses to Review

Addressing reviewer feedback point by point before the revised plan body. Items marked **Accepted**, **Accepted with modification**, or **Pushback**.

### Phase 1 feedback

**`@Observable` injection mechanism change not documented — ACCEPTED**
Correct omission. The plan didn't list the full view migration. Added explicitly to Phase 1 below.

**Missing sort in computed `displayedPlates` — ACCEPTED**
Clear regression. Sort is included in the computed property definition below.

**`date = nil` breaks plist decoder — ACCEPTED with modification**
Reviewer is right that the current `decode(String.self, forKey: .date)` will throw if the key is absent. However, the recommended fix is `decodeIfPresent` with a `nil` default — not reverting to the empty string `""` sentinel. Nil is semantically correct ("no date recorded") and `""` is a meaningless placeholder. The decoder change is one line and cleaner. Both `LicensePlateModel` and any saved plist data need to be consistent: nil means unfound, an ISO8601 string means found. See Phase 1 changes below.

**`LicensePlateViewModel` — ACCEPTED, clarified**
Reviewer is right: "evaluate" implies uncertainty that doesn't exist. Having now read the file, it's clearly dead — no view or other file instantiates or references it. It also contains its own (older) copy of the date migration logic that predates `LicensePlateModel` taking over that responsibility. Delete it in Phase 1, not Phase 2.

### Phase 2 feedback

**`AppModel` → `PlatesViewModel` rename: judgment call — ACCEPTED with modification**
The reviewer presents the case against (noise, churn). My position: the rename is still worth doing — `AppModel` is a misleading name in a codebase trying to use MVVM — but the reviewer's mitigation is correct: do it as a single standalone commit (automated find-replace) separate from any structural changes. That makes it trivially reviewable and easily reverted if needed. Plan updated to reflect this.

### Phase 3 feedback

**`MockDataStore` in main target — ACCEPTED**
Keep in main target, wrap in `#if DEBUG`, use `@testable import` in tests. This is already the pattern used by `DeveloperToolsView`.

**`DataStore` tests need temp directory — ACCEPTED**
Real concern: tests that write to the actual Documents directory leak state between runs. Fix requires a small refactor to `DataStore` — accept a configurable base URL rather than always resolving the Documents directory internally. Added to Phase 3.

### Phase 4 feedback

**`NavigationStack` + custom header conflict — ACCEPTED, decision made**
Reviewer is correct that this isn't a minor step. Recommending **Option 2**: migrate app title and gear button into `.navigationTitle` and `.toolbar`, remove `AppHeaderView`. Rationale: `AppHeaderView` is essentially a hand-built reimplementation of what `NavigationStack` gives you natively. Migrating to the native bar means Liquid Glass works automatically in Phase 5, the layout is simpler, and we remove a custom component. The "All 50 Plates" title maps naturally to `.navigationTitle` and the gear icon maps to a `.toolbar` trailing item. This is a design decision that needs Jim and Eric's sign-off before Phase 4 begins — flagged as a decision gate in the open questions.

### Phase 5 feedback

**iOS 26 availability — PUSHBACK**
The reviewer states "as of April 2026, iOS 26 has not been officially released." This appears to be an error. iOS 26 was announced at WWDC June 2025 and follows Apple's standard fall release cadence — it would have shipped September/October 2025. As of April 2026, iOS 26 has been publicly available for approximately six months. The concern about API stability during beta is valid, but the plan already uses `#available` guards which handle any remaining rough edges. No change to the plan on this point. Reviewer to confirm or correct.

**`SegmentsView` needs Eric's involvement — ACCEPTED**
The internal `RoundedRectangle` fill inside `SegmentsView` would paint over any glass container wrapping it. This needs Eric's involvement and is flagged explicitly. Added evaluation task: check whether native `Picker` with `.pickerStyle(.segmented)` adopts Liquid Glass automatically on iOS 26 before deciding whether to modify `SegmentsView` at all.

**Dynamic Type with custom fonts — ACCEPTED**
Reviewer is right: Futura doesn't scale with Dynamic Type automatically, and the current fixed-size font constants are not Dynamic Type compatible. This is real engineering work (`UIFontMetrics` scaling), not just a verification step. Added as an explicit decision gate in Phase 5: either plan the `UIFontMetrics` work or record an explicit product decision to skip Dynamic Type support for now.

### New open questions from review

All three accepted and added to the open questions section. Q9 (`LicensePlateViewModel` deletion) is now resolved — delete in Phase 1.

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
- Derived state (`displayedPlates`, counts) stored as manually-synced `@Published` vars — every mutation site calls `refreshDisplayedPlates()` + `updateCounts()` by hand
- `aboutIsShowing: Bool` is UI presentation state living inside the model
- `tapped(plate:)` mutates via `removeAll` + `append`
- `saveState()` only triggered on app background — a crash mid-session loses data
- Legacy `listIsFiltered` UserDefaults migration code is dead weight
- `LicensePlateView` holds an `@EnvironmentObject var model: AppModel` it never uses
- `LicensePlateViewModel` is entirely unreferenced dead code — delete it

### Changes

**Adopt `@Observable` (iOS 17+)**

Replace `ObservableObject` + `@Published` with the `@Observable` macro. Drop `import Combine`. With `@Observable`, any stored property change triggers view updates automatically, including through computed properties — so manual refresh calls disappear.

**Full injection mechanism migration — every file**

`@Observable` uses different injection than `ObservableObject`. All of the following change:

| Location | Before | After |
|---|---|---|
| `All_50_PlatesApp.swift` | `@StateObject var appModel = AppModel(...)` | `@State var viewModel = PlatesViewModel(...)` |
| `All_50_PlatesApp.swift` | `.environmentObject(appModel)` | `.environment(viewModel)` |
| All view files | `@EnvironmentObject var model: AppModel` | `@Environment(PlatesViewModel.self) var model` |
| `FilterSelectorView` | Custom `Binding<Int>` wrapping model | `@Bindable var model: PlatesViewModel` then `$model.filterState` |

Affected view files: `LicensePlateListView`, `AppHeaderView`, `GameProgressView`, `FilterSelectorView`, `AboutView`. (`LicensePlateView`'s environment object reference is deleted entirely — see below.)

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

`refreshDisplayedPlates()`, `updateCounts()`, `sortPlates()`, and `countFor(state:)` are all deleted.

**Fix `date` handling — use `nil` not `""`**

Change `LicensePlateModel`'s decoder to use `decodeIfPresent`:
```swift
date = try values.decodeIfPresent(String.self, forKey: .date)
```
Unfound plates store `date = nil`. Found plates store an ISO8601 string. The `""` sentinel from the seed `plates.plist` is handled gracefully: `decodeIfPresent` returns `""` if the key exists with an empty string value, and the existing `updateDateFormat()` method produces no output for an empty string, leaving `date` as `""` — which `dateDisplay` already handles by returning `""`. Seed data does not need to change.

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

Call `saveState()` from `tapped()` and `reset()` directly. Keep the `scenePhase` background hook as safety net only.

**Move `aboutIsShowing` to the view layer**

`LicensePlateListView` owns `@State var aboutIsShowing = false`. `AppHeaderView` receives a closure or binding rather than reading the model.

**Remove legacy migration**

Delete the `listIsFiltered` UserDefaults read in `init`. Any user still on that path defaults to `.allPlates`.

**Delete `LicensePlateView`'s unused environment object**

**Delete `LicensePlateViewModel.swift` entirely**

Unreferenced dead code. Contains an older, duplicate copy of date migration logic now handled by `LicensePlateModel`.

### Resulting file changes
- `AppModel.swift` → renamed `PlatesViewModel.swift` (see Phase 2 note)
- `All_50_PlatesApp.swift`
- `LicensePlateListView.swift`
- `LicensePlateView.swift`
- `AppHeaderView.swift`
- `GameProgressView.swift`
- `FilterSelectorView.swift`
- `AboutView.swift`
- `LicensePlateModel.swift` (decoder fix)
- Delete `LicensePlate/LicensePlateViewModel.swift`

---

## Phase 2 — MVVM Structure
*Cleaner boundaries. Still no visible user changes.*

### Rename `AppModel` → `PlatesViewModel`

Do this as a **single standalone commit** — automated find-replace across all files, nothing else in that commit. This makes the rename trivially reviewable in isolation and easily reverted. Do not mix structural changes into the same commit.

Rationale for doing it: `AppModel` is a misleading name in a codebase organized around MVVM. The cost of the rename is low when isolated to its own commit; the benefit is a codebase that reads consistently.

### View coupling audit

- `FilterSelectorView` uses `@Bindable var model: PlatesViewModel` and passes `$model.filterState` to `SegmentsView` — clean after Phase 1 changes
- `AppHeaderView` no longer touches the ViewModel for sheet presentation (fixed in Phase 1)
- `GameProgressView` reads computed properties from the ViewModel — acceptable

### File/folder cleanup

- Move `EmptyListView` out of `LicensePlateListView.swift` → `Views/EmptyListView.swift`
- Move `MyButtonStyle` → `Components/PlateButtonStyle.swift` (rename while moving)
- Evaluate `SettingsView.swift` — likely dead; `AboutView` covers this ground already. Delete if unreferenced.
- Consolidate `AboutListCell` and `CompanyView` (currently inline in `AboutView.swift`) — leave in place unless they grow

### Target folder structure
```
Models/
    LicensePlateModel.swift
    ListFilterState.swift
ViewModels/
    PlatesViewModel.swift
Repositories/
    DataStore.swift
    MockDataStore.swift          (wrapped in #if DEBUG)
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
*Zero tests currently. This phase adds a safety net before UI work begins.*

### Prerequisite refactor: `DataStore` configurable base URL

Before writing `DataStore` tests, refactor `DataStore` to accept a base `URL` in its initializer (defaulting to the Documents directory). Tests pass a temporary directory created in `setUp` and deleted in `tearDown`, preventing real file system leakage between runs.

```swift
class DataStore: LicensePlateStoreProtocol {
    private let baseURL: URL
    
    init(baseURL: URL = FileManager.default.urls(for: .documentDirectory, 
                                                  in: .userDomainMask)[0]) {
        self.baseURL = baseURL
    }
    // ...
}
```

### Add `All 50 PlatesTests` XCTest target

Use `@testable import All_50_Plates` to access `MockDataStore` and internal types.

**`LicensePlateModelTests`**
- Old format (`"MMMM d, yyyy"`) converts to ISO8601 on decode
- ISO8601 string passes through unchanged
- Empty string produces empty `dateDisplay`
- `nil` date produces empty `dateDisplay`
- `id` equals the 2-letter plate code

**`PlatesViewModelTests`**
- `tapped()` sets `found = true` and a non-nil date on first call
- `tapped()` sets `found = false` and `date = nil` on second call
- `numberFound` + `numberRemaining` always sum to `totalPlates`
- `displayedPlates` returns all plates for `.allPlates`
- `displayedPlates` returns only found plates for `.found`
- `displayedPlates` returns only unfound plates for `.notFound`
- `displayedPlates` is always sorted A→Z regardless of filter
- `reset()` sets all plates to `found = false`, `date = nil`
- `filterState` change persists to UserDefaults

**`DataStoreTests`**
- Encode → decode round-trip produces identical plate array
- `fetch()` returns bundle data when no saved file exists
- `fetch()` returns saved file data when saved file exists
- `reset()` removes the saved file
- All tests use temp directory, not real Documents directory

**`MockDataStore`**
Keep in main target under `#if DEBUG`. Ensure it includes the legacy date format fixture (`"MMMM d, yyyy"`) intentionally — this documents and tests the migration requirement.

---

## Phase 4 — Adaptive Layout: iPhone + iPad

### Decision gate: `AppHeaderView` fate
**Must be resolved before Phase 4 begins.**

`LicensePlateListView` uses a custom `AppHeaderView` (hand-built HStack). Adding `NavigationStack` creates a duplicate nav bar on top of it. Options:

1. Hide native nav bar, keep custom header → Liquid Glass doesn't apply automatically in Phase 5
2. **Migrate to native nav bar, remove `AppHeaderView`** → Liquid Glass works automatically, simpler layout

**Recommendation: Option 2.** `AppHeaderView` is essentially a reimplementation of what `NavigationStack` gives natively. The "All 50 Plates" title maps to `.navigationTitle`. The gear button maps to a `.toolbar` trailing item. The custom Futura font title can be applied via `.navigationBarTitleDisplayMode` + `UINavigationBarAppearance` if needed.

This is a design call that affects Eric's work. Needs explicit sign-off from Jim and Eric before proceeding. If the answer is "keep the custom header," revise Phase 5 to drop the automatic Liquid Glass nav bar adoption and plan a manual glass treatment for `AppHeaderView` instead.

### iPhone (refined baseline)

- Wrap root in `NavigationStack`
- App title + gear button move to `.navigationTitle` / `.toolbar` (pending decision gate above)
- Plate row image width: proportional to screen width (`geometry.size.width * 0.35`) rather than hardcoded `125pt`
- Hardcoded `72pt` heights replaced with dynamic sizing
- Landscape iPhone: verify list adjusts gracefully

### iPad

- `@Environment(\.horizontalSizeClass)` drives layout branching
- **Regular width (iPad)**: `NavigationSplitView`
  - Sidebar: game progress stats, filter controls, About/Reset button
  - Detail: plate list (single column portrait) or grid (landscape)
- **Compact width (iPhone)**: current vertical stack, refined
- iPad grid uses `LazyVGrid` with adaptive columns:
  ```swift
  LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) { ... }
  ```
- Review `feature/ipad` stash (`stash@{0}`) for salvageable work before starting

### Shared components

- Single `LicensePlateView` works in both list and grid context (adjust proportions)
- `EmptyListView` works unchanged in both contexts

---

## Phase 5 — Design: Liquid Glass + Light/Dark Mode

### Dynamic Type decision gate
**Must be resolved before Phase 5 begins.**

Futura is not a system font and does not scale with Dynamic Type automatically. The current `FontUtils.swift` uses fixed point sizes. True Dynamic Type support requires `UIFontMetrics` to scale custom fonts — this is real engineering work, not a quick check. Make an explicit decision:

- **Option A**: Implement `UIFontMetrics` scaling for all custom font sizes. Fully accessible, more engineering work.
- **Option B**: Record an explicit product decision that this app uses fixed-size custom fonts and does not support Dynamic Type. Document this in `FontUtils.swift` with a comment so future contributors understand it's intentional.

Either is a valid call. Just needs to be made explicitly.

### Light/Dark mode (all iOS versions)

Every named color in `Assets.xcassets` needs Light and Dark appearance variants added. Current colors have no variants — the app ignores system appearance entirely.

| Color name | Light | Dark |
|---|---|---|
| AppBackground | Light gray/white | Near-black |
| AppCardBackground | White | Dark gray |
| AppDark | Dark navy/charcoal | Slightly lighter dark |
| AppLight | White | Off-white |
| AppText | Near-black | Near-white |
| AppSubtext | Medium gray | Light gray |
| AppButtonText | White | White |
| AppGray | Medium gray | Dark gray |

**Exact values to be defined with Eric.** This is design work, not just a code change.

### iOS 17–25: Material fallback design

For users on iOS 17–25, a clean polished design using SwiftUI `Material`:
- Header/nav area: `.ultraThickMaterial` background (or native nav bar)
- Filter bar: `.regularMaterial` background with custom selection highlight
- Plate cards: `.thinMaterial` or solid `AppCardBackground` with refined border
- Progress bar: clean rounded rect, no `scaleEffect` hack

### iOS 26+: Liquid Glass

Wrap iOS 26 features in `if #available(iOS 26, *) { } else { }`.

Note: iOS 26 shipped fall 2025 and has been publicly available for approximately six months as of this writing. These are stable APIs, not beta.

- **Navigation bar**: `NavigationStack` adopts Liquid Glass automatically. No code needed.
- **Filter bar**: Evaluate native `Picker` with `.pickerStyle(.segmented)` first — it may adopt Liquid Glass automatically, requiring no changes to `SegmentsView`. If not, wrap `SegmentsView` in `GlassEffectContainer` and pass `backgroundColor: .clear` to prevent its internal fill from painting over the glass effect. **Either path requires Eric's review** — `SegmentsView` is his component.
- **Progress area**: Float above list with `.glassEffect()` background
- **About/Reset button**: `.buttonStyle(.glassProminent)`
- **Plate cards**: Do NOT apply glass to list content — Apple's guidelines explicitly reserve glass for the navigation layer

### Key constraint
`.glassEffect()` cannot sample other glass. Use `GlassEffectContainer` for any adjacent glass elements.

### Typography
Pending Dynamic Type decision gate above. Font constants in `FontUtils.swift` and `ISFont.swift` otherwise remain as-is — Futura fits the license plate aesthetic.

---

## Phase 6 — License Plate Images

**Deferred pending asset delivery from Jim.**

### SVG editing capability
SVG files are XML text — editable directly. Colors, fills, strokes, and gradients can be added or modified. Once the pattern is established for one plate, it can be applied consistently across all 51 files.

### Recommended approach: single SVG + SwiftUI state handling
Keep one SVG per plate. Handle found/unfound appearance in SwiftUI (current opacity approach, or a different treatment). This is simpler to maintain than managing 102 assets.

### Asset replacement process
1. Review new SVG structure (paths, viewBox, existing fills)
2. Apply any color corrections
3. Drop into `Assets.xcassets/Plates/` — image names (2-letter state code) stay the same, no code changes required
4. Verify rendering in list row and grid contexts

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

1. **Eric Ziegler availability** — Three concrete things need his sign-off before Phases 4–5 begin:
   - `AppHeaderView` fate (replaced by native nav bar, or kept custom)
   - All named colors need Light/Dark variants defined with him
   - `SegmentsView` will need modification for Liquid Glass (internal background conflicts with glass container)

2. **`AppHeaderView` fate** — Decision gate for Phase 4. Option 2 (native nav bar) recommended. Needs Jim + Eric sign-off.

3. **Dynamic Type** — Decision gate for Phase 5. Implement `UIFontMetrics` scaling, or explicitly accept fixed-size fonts. Needs Jim's call.

4. **New plate images** — Where are the files? What format?

5. **Washington DC** — Entry 51. Intentional inclusion? Keep or remove?

6. **`feature/swipe-to-find` branch** — Abandoned due to UX issues with filtered lists. Revisit after adaptive layout, or permanently close?

7. **App Store release timing** — Target date for shipping? Helps prioritize which phases are blocking.

8. **`feature/convert-to-classes` branch** — `@Observable` requires classes. This branch's intent is satisfied by Phase 1. Close it.
