# KLUKK — App Store Connect Metadata

Everything below is ready to paste into App Store Connect. Character limits noted in
parentheses; all entries are within limit.

---

## App information

| Field | Value |
|-------|-------|
| **App name** (30) | `KLUKK` |
| **Subtitle** (30) | `Time it. Send it to Calendar.` |
| **Bundle ID** | `ehf.nnv.klukk` |
| **SKU** | `klukk-ios-001` |
| **Primary language** | English (U.S.) |
| **Primary category** | Productivity |
| **Secondary category** | Utilities |
| **Copyright** | `© NNV ehf.` |

---

## Promotional text (170)

> One tap to start, one tap to stop — and your timed session lands straight in your
> calendar. No accounts, no clutter. Just you and the big pink button.

---

## Description (4000)

KLUKK is the stopwatch that remembers for you.

Tap the big pink button to start timing. Tap it again to stop, and the session is
saved instantly as a real event in your iOS Calendar — already named, dated, and
placed on the right day. No forms, no logbook, no copy-and-paste.

Whether you bill by the hour, track focus blocks, log workouts, time your practice,
or just want an honest record of where your day went, KLUKK turns the seconds you
measure into something you can actually look back on.

WHY KLUKK

• One-tap stopwatch — start and stop from a single button, with a satisfying
  woodblock click and a gentle haptic.
• Straight to your calendar — every session becomes a native iOS Calendar event,
  so it shows up alongside everything else you already track.
• Pick your calendar — save to any writable calendar, or create a brand-new one
  for your sessions right inside the app.
• Centisecond precision — watch the hundredths tick by, or switch them off for a
  calmer face.
• Name it your way — title templates fill in the time, date, count, and duration
  automatically (for example "Session 3 · 14:20"), or rename each session after you
  stop.
• Other destinations — prefer files? Export any session as a standard .ics calendar
  file to share, or append to a local .xml log.
• Yours alone — KLUKK has no account, no sign-up, and no tracking. Your sessions
  stay on your device and in the calendar you choose.

KLUKK is designed to be the fastest distance between "go" and "logged." Open it,
tap once, get on with your work — and trust that it's all written down.

Built by NNV ehf.

---

## Keywords (100, comma-separated, no spaces after commas)

```
stopwatch,timer,calendar,time tracker,timesheet,hours,billable,focus,log,ics,session,track,productivity
```

---

## What's New (release notes — v1.0)

```
First release of KLUKK.

• One-tap stopwatch that saves each session straight to your iOS Calendar
• Create or pick the calendar sessions go into
• Centisecond precision, customizable title templates, and rename-on-stop
• Export sessions as .ics files or append to a local .xml log
• Woodblock click and haptic feedback

Thanks for trying KLUKK. We'd love your feedback.
```

---

## URLs

| Field | Value | Status |
|-------|-------|--------|
| **Support URL** | `https://nnv.is/klukk/support` | ⚠️ ACTION NEEDED — must resolve before review |
| **Marketing URL** (optional) | `https://nnv.is/klukk` | ⚠️ optional, leave blank if not ready |
| **Privacy Policy URL** | `https://nnv.is/klukk/privacy` | ⚠️ ACTION NEEDED — required, must resolve |

> Apple requires a reachable Support URL and Privacy Policy URL. If nnv.is pages
> aren't live yet, a single static page each is enough. A ready-to-publish privacy
> policy is in `AppStore/privacy-policy.md`.

---

## App Privacy ("nutrition label")

Answer the App Privacy questionnaire in App Store Connect as follows. This matches
the bundled `PrivacyInfo.xcprivacy`.

- **Do you collect data from this app?** → **No.**

KLUKK collects nothing. Sessions are stored locally and written only to the calendar
the user explicitly chooses. There is no analytics, no advertising, no third-party
SDKs, and no tracking.

- Tracking: **No**
- Data linked to you: **None**
- Data not linked to you: **None**

---

## Age rating

Answer all content questions **None / No**. Expected rating: **4+**.

---

## Review information (for App Review team)

| Field | Value |
|-------|-------|
| **Sign-in required?** | No |
| **Demo account** | Not applicable — no account system |
| **Contact first/last name** | _your name_ |
| **Contact phone** | _your number_ |
| **Contact email** | nordnordvestur@gmail.com |
| **Notes** | KLUKK is a stopwatch that saves timed sessions to the iOS Calendar. On first launch it asks where to send sessions; choosing "iOS Calendar" triggers the system Calendar permission prompt. Grant Full Access to allow saving events and creating new calendars. No login is required. |

---

## Build / signing facts

| Field | Value |
|-------|-------|
| **Version (MARKETING_VERSION)** | 1.0 |
| **Build (CURRENT_PROJECT_VERSION)** | 1 |
| **Deployment target** | iOS 18.0 |
| **Devices** | iPhone + iPad (universal) |
| **Orientations** | iPhone portrait; iPad all |
| **Team** | WS56KAUU82 |
| **Calendar usage string** | "Klukk saves your stopwatch sessions in your calendar." |

---

## Screenshots

Located in `AppStore/screenshots/`. Captured at exact App Store pixel sizes.

| File | Device class | Size |
|------|--------------|------|
| `iphone69_1_onboarding.png` | iPhone 6.9" | 1320 × 2868 |
| `iphone69_2_hero.png` | iPhone 6.9" | 1320 × 2868 |
| `ipad13_1_onboarding.png` | iPad 13" | 2064 × 2752 |
| `ipad13_2_hero.png` | iPad 13" | 2064 × 2752 |

The 6.9" iPhone set also satisfies the 6.5" requirement (App Store Connect reuses it).
