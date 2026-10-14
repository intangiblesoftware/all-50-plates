# Refactoring Plan Review

**Reviewed by**: Claude (second instance)
**Date**: April 2026
**Based on**: reading REFACTORING_PLAN.md + current source files

Overall the plan is solid and well-sequenced. The issues below range from blocking bugs to judgment calls.
They're grouped by phase for easy cross-reference.

---

## Phase 1 — AppModel Refactor

### Critical: `@Observable` requires changing the injection mechanism everywhere

The plan describes replacing `ObservableObject` + `@Published` with `@Observable`, but doesn't mention that `@Observable` also replaces `@EnvironmentObject` / `@StateObject`. These are different protocols and the injection mechanism changes:

| Current (ObservableObject) | After @Observable |
|---|---|
| `@StateObject var appModel = AppModel(...)` | `@State var appModel = AppModel(...)` |
| `.environmentObject(appModel)` | `.environment(appModel)` |
| `@EnvironmentObject var model: AppModel` | `@Environment(AppModel.self) var model` |

Every view file in the app uses `@EnvironmentObject var model: AppModel`. That's:
`LicensePlateListView`, `LicensePlateView`, `AppHeaderView`, `GameProgressView`, `FilterSelectorView` — all of them need to change. `All_50_PlatesApp.swift` needs to change too.

This is a load-bearing omission. If someone picks up Phase 1 without knowing this, they'll adopt `@Observable` on the model and get compile errors in every view. Add this to the Phase 1 changes list explicitly.

For `FilterSelectorView` specifically, which needs a `Binding` to `filterState`: with `@Observable`, you'd use `@Bindable var model: AppModel` inside the view and pass `$model.filterState` to `SegmentsView`. The plan mentions passing filterState as a binding but doesn't show the `@Bindable` pattern.

### Bug: computed `displayedPlates` is missing the alphabetical sort

The current `refreshDisplayedPlates()` calls `sortPlates()` after filtering — plates are always displayed A→Z. The plan's computed property replacement doesn't include `.sorted { $0.state < $1.state }`. This would be a regression. The computed property needs to be:

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
```

### Concern: `date = nil` breaks the current plist decoder

The plan's new `tapped()` sets `date` to `nil` for unfound plates. But `LicensePlateModel`'s decoder currently uses:
```swift
date = try values.decode(String.self, forKey: .date)
```
Not `decodeIfPresent`. If a plate is saved with `date` absent from the plist (nil → PropertyListEncoder omits the key), this line throws on the next fetch. The bundle seed data `plates.plist` uses empty strings `""` for unfound plates, which decodes fine — but any plate marked unfound under the new code would use `nil`.

Either keep `""` as the unfound sentinel (change `nil` → `""` in `tapped()`), or change the decoder to use `decodeIfPresent` with a `nil` default. Either works; just needs to be explicit.

### Minor: `LicensePlateViewModel` is dead code — delete, don't evaluate

The plan says "evaluate and either delete or give it a clear purpose." There's no evaluation needed: `LicensePlateViewModel` is referenced only in its own file. No other file imports or instantiates it. The plan's language implies uncertainty; there is none. Delete it in Phase 1 (or Phase 2).

---

## Phase 2 — MVVM Structure

### Judgment call: is the `AppModel` → `PlatesViewModel` rename worth it?

This rename touches every file that references `AppModel` — all five view files plus the entry point, plus the repositories, plus tests once they exist. That's mechanical churn with no behavior change.

The argument for it: "ViewModel" correctly names what it is in MVVM.
The argument against: `AppModel` is already understood by everyone working on the project, and the rename creates noise in the diff that obscures the real structural changes happening in the same phase.

Worth discussing with Jim before committing to this. If the rename happens, do it as a standalone commit (automated find-replace) so it's easily reviewable in isolation.

---

## Phase 3 — Testing

### `MockDataStore` is in the main target; tests need access to it

`MockDataStore` currently lives in the main app target. XCTest targets can import the app module, but this is fragile (needs `@testable import`). If `MockDataStore` is intended as a test double, consider moving it to the test target. If it's also used in SwiftUI previews (it is — several preview providers use it), it needs to stay in the main target or be duplicated.

The simplest resolution: keep `MockDataStore` in the main target (wrapped in `#if DEBUG` like `DeveloperToolsView`), use `@testable import` in tests.

### `DataStore` tests need a temp directory, not the real Documents directory

A `DataStore` test that calls `store()` and `fetch()` using the actual Documents directory will create real files in the simulator's sandbox. Tests that run in sequence can leak state to each other. The `DataStoreTests` should initialize `DataStore` with a configurable base URL (a temp directory created in `setUp` and deleted in `tearDown`), or use a mock filesystem. This requires a small refactor to `DataStore` — probably worth doing in Phase 3, not an afterthought.

---

## Phase 4 — Adaptive Layout

### The `NavigationStack` addition is not a free change — it conflicts with the custom header

The plan presents wrapping in `NavigationStack` as a minor setup step ("sets up Phase 5 automatically"). But `LicensePlateListView` currently uses a custom `AppHeaderView` — a hand-built `HStack` with the app title and gear button — not a native navigation bar. When you add `NavigationStack`, SwiftUI adds a native nav bar on top of the existing layout. You'd get both.

The options are:
1. Hide the native nav bar (`navigationBarHidden(true)` or `.toolbar(.hidden)`) and keep the custom header — but then Liquid Glass won't apply automatically in Phase 5.
2. Migrate the app title and gear button into `.navigationTitle` and `.toolbar` items, and remove `AppHeaderView` — then Liquid Glass works automatically but the visual design changes.

Option 2 is the right call for Phase 5 to work as described, but it means `AppHeaderView` (Eric's design territory) goes away and the identity of the app's top bar is now a native nav bar. That's a design decision that needs to be made explicitly, not assumed.

Flag this as a decision gate before starting Phase 4.

---

## Phase 5 — Liquid Glass + Light/Dark Mode

### iOS 26 availability is uncertain; plan should acknowledge this

As of April 2026, iOS 26 has not been officially released. If the team is working against beta SDK, the `GlassEffect` APIs may change before shipping. The plan should note that Phase 5's iOS 26 features are conditional on SDK availability and may need to wait for a stable release.

### `SegmentsView` needs Eric's involvement before Liquid Glass wrapping

The plan says to wrap `SegmentsView` in a `GlassEffectContainer` for the filter bar. `SegmentsView` (authored by Eric) has its own internal background rendering — a `RoundedRectangle` fill with a configurable `backgroundColor`. If you wrap it in a glass container, the component's own background will paint over the glass effect. You'd need to either:
- Remove the internal background from `SegmentsView` and let the glass container handle it, or
- Pass `backgroundColor: .clear` at the call site.

Either way, this is a modification to Eric's component. Flag it explicitly as "needs Eric review" rather than treating it as an implementation detail.

An alternative worth evaluating: SwiftUI's native `Picker` with `.pickerStyle(.segmented)` may adopt Liquid Glass automatically on iOS 26 without any glass API work. If it does, replacing the custom `SegmentsView` with native `Picker` could be less work and give you Liquid Glass for free. Evaluate this before deciding to modify `SegmentsView`.

### Dynamic Type with custom fonts is more than a "verify"

The plan says "verify all weights are embedded correctly and review sizing for Dynamic Type compatibility." Futura is not a system font and does not scale with Dynamic Type automatically. The current `FontUtils.swift` uses fixed point sizes (`.appControl`, `.appText`, etc.). True Dynamic Type support requires using `UIFontMetrics` to scale custom fonts. This is a meaningful engineering task, not a verification. Either accept "fixed size, no Dynamic Type" as a deliberate product decision, or plan the work explicitly.

---

## Phase 6 — License Plate Images

No significant issues. The plan is appropriately deferred pending asset delivery. The note to keep found/unfound state in SwiftUI (single SVG + opacity) is the right call — simpler to maintain.

---

## Open Questions — Additions

The existing open questions are real blockers, as noted. Adding three more:

**7. `AppHeaderView` fate in Phase 4**: Does it become toolbar content in a `NavigationStack`, or does the team keep the custom header and forfeit automatic Liquid Glass? This blocks Phase 4 design decisions.

**8. Eric's availability for Phases 4–5**: The plan notes Eric's involvement as an open question, but it's worth being specific: `SegmentsView` will need modification for Liquid Glass, all named colors need light/dark variants defined with him, and `AppHeaderView` may be eliminated. That's three concrete things that need his sign-off before those phases start.

**9. `LicensePlateViewModel` deletion**: Confirm deletion is safe (it is — it's unreferenced) and do it in Phase 1 or Phase 2. Leaving it unaddressed will confuse anyone reading the codebase.

---

## Summary of Blocking Issues

| Issue | Phase | Risk if missed |
|---|---|---|
| `@Observable` injection mechanism change not in plan | 1 | Compile errors in all view files |
| Missing sort in computed `displayedPlates` | 1 | Regression: plates appear in random order |
| `date = nil` breaks plist decoder | 1 | Crash on next fetch after marking plate unfound |
| `NavigationStack` + custom header conflict | 4 | Broken layout or Liquid Glass doesn't apply |
| `DataStore` test isolation | 3 | Flaky/leaky tests |
