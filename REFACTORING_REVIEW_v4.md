# Refactoring Plan v4 Review

**Reviewed by**: Claude (second instance, fourth pass)
**Date**: April 2026
**Based on**: REFACTORING_PLAN_v4.md + source files

All v3 items are correctly resolved. Two new issues found — both in Phase 1, both have the potential to cause silent failures at runtime.

---

## Issue 1: `LicensePlateModel.encode(to:)` needs `encodeIfPresent` — not just the decoder

The plan correctly adds `decodeIfPresent` to the decoder so a missing `date` key reads as `nil`. But it doesn't update the encoder. The current `encode(to:)` in `LicensePlateModel` is:

```swift
try container.encode(date, forKey: .date)   // date is String?
```

After Phase 1, `date` can be `nil` (unfound plates). When `PropertyListEncoder` tries to encode `Optional<String>.none`, it calls `encodeNil()` on the keyed container. Property List format does not have a null type — this throws. The current `DataStore.encode()` catches errors silently and just prints them, so `saveState()` would fail without any user-visible indication. Every plate marked unfound after tapping would fail to persist.

The fix is one line in `LicensePlateModel`:

```swift
// Before
try container.encode(date, forKey: .date)

// After
try container.encodeIfPresent(date, forKey: .date)
```

`encodeIfPresent` omits the key when `nil` — exactly what's needed. `decodeIfPresent` then reads an absent key as `nil`. The round-trip is correct.

**Add this to the Phase 1 file changes list for `LicensePlateModel.swift`.** The plan currently only mentions the decoder change there.

---

## Issue 2: `FilterSelectorView` should use `@Environment`, not `@Bindable`

The Phase 1 injection table has:

```
FilterSelectorView | @EnvironmentObject var model: AppModel | @Bindable var model: AppModel
```

`@Bindable` as a stored property declaration does not inject from the environment. It means "this value is passed in directly as a parameter." If you write `@Bindable var model: AppModel` on a property with no default, `FilterSelectorView` would need to be initialized as `FilterSelectorView(model: someModel)` — but it's currently called as just `FilterSelectorView()` with no arguments, and that won't change in Phase 1.

What you want for Phase 1 is the same pattern as every other view: `@Environment(AppModel.self) var model`. The custom `Binding<Int>` bridge in `FilterSelectorView` doesn't require `@Bindable` — the get/set closures just read and write `model.filterState` directly on the class instance, which works fine from an `@Environment`-injected reference.

`@Bindable` becomes relevant in Phase 2, when `SegmentsView` is updated to accept `Binding<ListFilterState>` and `FilterSelectorView` needs to pass `$model.filterState`. At that point, the correct pattern is to use `@Environment` to get the model and `@Bindable` as a local in the body to create the binding:

```swift
@Environment(AppModel.self) private var model

var body: some View {
    @Bindable var model = model          // local, enables $model.filterState
    FilterSelectorView(filterState: $model.filterState)
    // ...or within FilterSelectorView itself:
    SegmentsView(..., filterState: $model.filterState, ...)
}
```

Or — perhaps cleaner for Phase 2 — `FilterSelectorView` could drop the model entirely and just take `Binding<ListFilterState>` as a parameter, letting the parent create the binding. That would match MVVM's goal of reducing view-model coupling.

**Fix for Phase 1**: change the `FilterSelectorView` row in the injection table to `@Environment(AppModel.self) var model`, consistent with all other views.

---

## Everything Else Looks Correct

- `reset()` implementation is now clean and correct
- `MockDataStore` `#if DEBUG` wrapping is now an explicit Phase 2 task
- `SegmentsView` typed binding update is now a concrete Phase 2 task
- The `PlateListRow` / `PlateGridCard` split is correctly specified
- Decision gates are well-placed
- Test spec for `reset()` is correct (tests against both MockDataStore and real DataStore)
- All prior issues resolved

With the two fixes above, Phase 1 is ready to implement.
