# KLUKK! 1.1 — App Store update copy

## What's New (paste into the 1.1 version's release notes)

```
A big update. 🟤

• Dark mode — a warm brown night-time canvas; pick System / Light / Dark in Settings.
• Home Screen widget — start and stop the pink button without opening the app, in
  three sizes, with a live-ticking timer.
• Target timer — tap the time to set a goal (say, one hour). KLUKK plays an alarm
  when your running session reaches it, even with the phone locked.
• Every session now saves to your Calendar automatically — no more choosing a
  destination first. Export any session as .ics, or the whole log as .xml, anytime.
• Name presets — quick-pick titles (Work, Workout, Meditation…) when you save.
• Cleaner main screen: one calendar button showing your selected calendar.

Tap. Time. It's in your calendar.
```

## Promotional text (170 chars)

```
Now with dark mode, a Home Screen widget, and a target-time alarm. Every session
saves to your calendar automatically — export as .ics or .xml whenever you like.
```

## Description — REPLACE the old "choose a destination" copy

The live 1.0 description describes picking a destination (iOS Calendar / .ics / .xml)
up front. That model is gone. Update the relevant bullets to:

```
• Saved automatically — every session becomes a native iOS Calendar event in the
  calendar you choose. No forms, no destination to pick.
• Export anytime — share a single session as a .ics file, or your whole log as .xml,
  straight from the app.
• Target alarm — set a goal time and KLUKK rings when you reach it, even locked.
• Home Screen widget — start/stop without opening the app.
• Dark mode, name presets, centisecond precision, and rename-on-stop.
```

## Marketing screenshots

Existing `AppStore/screenshots/mkt_*` still apply for the hero/dark/destinations
panels. Consider adding a widget shot and a target-timer shot before submitting.

## Privacy / permissions note

1.1 adds **local notifications** (for the target alarm) — these are scheduled on the
device only, no server, no data collected. The App Privacy answer stays "No data
collected." Local notifications need no Info.plist usage string.

## Before submitting 1.1
- Bump `MARKETING_VERSION` → 1.1, `CURRENT_PROJECT_VERSION` → 2.
- Run the release gate (`/code-review ultra` + Fable 5 review + light/dark verify).
- Make the Support + Privacy Policy URLs resolve.
- Update the App Store **description** per above (the old destination copy is wrong now).
