# Klukk

A stopwatch for iPhone that turns your recorded sessions into calendar events.

Tap the big yellow **KLUKK** button to start timing. Tap again to stop, and the elapsed session is saved to your chosen iOS Calendar (or exported as `.ics` / appended to a local `.xml`).

## Features

- One-tap stopwatch with centisecond precision
- Save sessions to any writable iOS Calendar
- Create new calendars from inside the app
- `.ics` file share and `.xml` append as alternative destinations
- Configurable title templates (`{time}`, `{date}`, `{n}`, `{duration}`)
- Optional rename-after-stop confirmation

## Requirements

- iOS 18.0 or later
- Xcode 16 or later (Swift 6)

## Build

Open `Klukk.xcodeproj` in Xcode and run on a simulator or device. The first save triggers an iOS calendar access prompt — grant **Full Access** so the app can also create new calendars.

## Contributing

After cloning, enable the repo's git hooks once:

```bash
git config core.hooksPath .githooks
```

The pre-commit hook auto-downgrades `objectVersion = 100` (Xcode 26 beta
format) to `77` in `project.pbxproj` so CI can still build. Without this,
Xcode beta's auto-upgrade on open silently breaks the GitHub Actions runner.

## License

© NNV ehf. All rights reserved.
