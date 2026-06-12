# KLUKK! 1.1 — Widgets + Alternate App Icons — Implementation Plan

Target release: **1.1 (build 2)** — features warrant a minor bump over the live 1.0.
Deployment target stays iOS 18, universal. Live 1.0 is untouched until we submit.

Build order is deliberately **risk-isolated**: each phase compiles, runs, and is
verifiable on its own before the next goes on top. The shared-storage migration (the
one thing that could corrupt user data) is its own phase with its own tests.

---

## Phase 0 — Signing & App Group registration

- Add App Group **`group.ehf.nnv.klukk`** to the App ID capabilities (via the App
  Store Connect API we already have wired, or auto-registered with
  `-allowProvisioningUpdates`).
- Add the **App Groups** entitlement to the app target (`Klukk.entitlements`).
- No code yet — verify the app still archives & signs with the new entitlement.

**Done when:** archive succeeds with the App Group entitlement present.

---

## Phase 1 — Alternate app icons  *(ship-first; fully self-contained, no shared storage)*

Lets the user pick a different Home Screen icon in Settings. Independent of widgets.

1. **Generate icon variants** (1024 masters → 120/180 px loose PNGs, opaque, no alpha):
   - Default `AppIcon` — current bead-on-skin (unchanged)
   - `IconClassic` — the original KLUKK-wordmark sphere  ← **the one alternate** (confirmed)
   - (structure makes adding more later trivial)
2. **Info.plist** → `CFBundleIcons` → `CFBundleAlternateIcons`: one entry per variant
   listing its `CFBundleIconFiles`. Alternate icons live as **loose PNGs in the bundle**,
   not in the asset catalog.
3. **Settings UI** — new "App Icon" section in `SettingsSheet.swift`: a row of taps that
   call `UIApplication.shared.setAlternateIconName("IconDark")` (nil = default). Persist
   the choice in `AppSettings` so the UI shows the current selection.

**Done when:** changing icon in Settings updates the Home Screen icon; survives relaunch.
**Risk:** low. Pure additive. Could even ship in 1.0.1 on its own if we want it sooner.

---

## Phase 2 — Shared storage refactor  *(the risky migration — isolated + tested)*

Move the data a widget needs into the App Group container, with safe one-time migration.

New file **`Klukk/Shared/AppGroup.swift`** (member of BOTH app + widget targets):
```swift
enum AppGroup {
    static let id = "group.ehf.nnv.klukk"
    static var container: URL { FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: id)! }
    static var defaults: UserDefaults { UserDefaults(suiteName: id)! }
}
```

1. **SessionStore** ([Stores/SessionStore.swift](Klukk-iOS/Klukk/Stores/SessionStore.swift))
   - Point `url` at `AppGroup.container/klukk-sessions.json`.
   - **Migration:** on init, if the old Documents file exists and the new one doesn't,
     copy it over (then it's the source of truth).
   - Call `WidgetCenter.shared.reloadAllTimelines()` after `add` / `clear`.
2. **AppSettings** ([Models/AppSettings.swift](Klukk-iOS/Klukk/Models/AppSettings.swift))
   - Swap `UserDefaults.standard` → `AppGroup.defaults`.
   - **Migration:** if the new suite has no value but `.standard` does, copy it once.
3. **Running state (new, shared)** — a tiny `RunningState` persisted to `AppGroup.defaults`:
   - `startedAt: Date?` and `target` written when the user starts, cleared on stop.
   - `StopwatchView.tapButton()` writes/clears it alongside the existing logic, so the
     widget can compute elapsed time and render a live count-up independently.

**Tests:** unit-test the migration (old file present → copied; new present → untouched;
neither → empty). **Done when:** app behaves identically to 1.0, now reading/writing the
shared container. **No widget yet** — verify this in isolation first.

---

## Phase 3 — Widget extension (read-only first)

1. New target **`KlukkWidgets`** (Widget Extension), bundle `ehf.nnv.klukk.KlukkWidgets`,
   App Group entitlement added.
2. Share `Session.swift`, `Format.swift`, `AppGroup.swift`, `RunningState` with the
   extension via target membership (the synchronized-folder structure needs these in a
   `Shared/` group both targets reference).
3. `TimelineProvider` reads sessions + running state from `AppGroup`. Computes today's
   total and recent sessions.
4. Views for **systemSmall / systemMedium / systemLarge** matching the approved mock —
   same 108 px bead, same 30 px timer; large = medium header + divider + recent list.
5. Live count-up while running via `Text(timerInterval:)` (system-driven, no battery cost).
6. **Dark mode:** the app now supports light (skin) + dark (RAL 8025 brown) via the
   `Background` color set in the asset catalog; the bead stays pink in both. The widget
   should **mirror this** — reuse the same `Background` color set (skin in light, brown in
   dark) so the widget matches the app on both light and dark Home Screens.

**Done when:** widget added to Home Screen shows real data and updates after a session.

---

## Phase 4 — Interactive pink button (App Intent)

1. **`ToggleTimerIntent: AppIntent`** (shared) — flips `RunningState`: start sets
   `startedAt`; stop computes the `Session`, appends to the shared store, clears running.
2. The bead becomes `Button(intent: ToggleTimerIntent())` — start/stop from the Home
   Screen without opening the app (iOS 18). Reuses one intent for the widget today, and
   for Control Center / Siri later for free.
3. **Calendar on stop — DECIDED: reconcile on next launch.** The widget records the session
   to the shared store immediately; the app writes pending sessions to the iOS Calendar on
   next launch (a reconcile pass over any sessions not yet delivered). No EventKit in the
   extension. Add a `delivered: Bool` flag to `Session` (or a pending-IDs set) so the app
   knows what to flush.

**Done when:** tapping the widget bead starts/stops timing and a session lands in the list.

---

## Phase 5 — Polish, version bump, ship

- Bump `MARKETING_VERSION` → **1.1**, `CURRENT_PROJECT_VERSION` → **2**.
- New screenshots showing the widget (and the alt-icon picker) for the listing.
- "What's New" copy for 1.1.
- Archive → upload → create 1.1 version → attach build → submit (all via the API path
  already proven for 1.0).

---

## Decisions — LOCKED
1. **Calendar-on-stop:** reconcile-on-launch. ✅
2. **Alternate icons:** default Pink + **Classic** (one alternate). ✅
3. **Scope:** widgets + alternate icon **together in 1.1**, next week. ✅
   (Your separate bug fixes still go in too — list them whenever ready.)

## Risks
- **Target membership** of shared files with the synchronized-folder project layout — the
  fiddliest config step; handled in Phase 3.
- **App Group provisioning** re-sign — handled in Phase 0.
- **Alt-icon Info.plist** sizes/keys — exact PNG sizes matter; handled in Phase 1.
