import Foundation

/// The user-selectable language preference. `system` follows the device language,
/// resolving to Icelandic on Icelandic devices and English everywhere else.
enum AppLanguage: String, Codable, CaseIterable, Sendable {
    case system
    case english = "en"
    case icelandic = "is"
}

/// A resolved (concrete) language — what `AppLanguage` collapses to once the
/// system locale is taken into account.
enum Lang: Sendable { case en, is_ }

enum Localization {
    /// Collapse a preference into a concrete language.
    static func resolve(_ pref: AppLanguage) -> Lang {
        switch pref {
        case .english: return .en
        case .icelandic: return .is_
        case .system:
            let code = Locale.preferredLanguages.first?.lowercased() ?? "en"
            return code.hasPrefix("is") ? .is_ : .en
        }
    }

    /// Language resolved from the preference persisted in the shared defaults.
    /// Used by code that has no `AppSettings` (the widget and `Format`).
    static var stored: Lang { resolve(SharedSettings.load().language) }
}

/// Every user-facing string, in English and Icelandic. Call sites pass the
/// resolved `Lang`; in the app that comes from `AppSettings.lang` (so flipping
/// the language switch re-renders instantly), elsewhere from `Localization.stored`.
enum L {
    static func pick(_ l: Lang, _ en: String, _ is_: String) -> String {
        l == .en ? en : is_
    }

    // MARK: Common
    static func close(_ l: Lang) -> String { pick(l, "Close", "Loka") }
    static func cancel(_ l: Lang) -> String { pick(l, "Cancel", "Hætta við") }
    static func create(_ l: Lang) -> String { pick(l, "Create", "Búa til") }
    static func add(_ l: Lang) -> String { pick(l, "Add", "Bæta við") }
    static func delete(_ l: Lang) -> String { pick(l, "Delete", "Eyða") }
    static func name(_ l: Lang) -> String { pick(l, "Name", "Nafn") }
    static func calendar(_ l: Lang) -> String { pick(l, "Calendar", "Dagatal") }
    static func defaultCalendar(_ l: Lang) -> String { pick(l, "Default", "Sjálfgefið") }

    // MARK: CalendarPickerView
    static func loadingCalendars(_ l: Lang) -> String { pick(l, "Loading calendars…", "Hleð dagatölum…") }
    static func saveEventsTo(_ l: Lang) -> String { pick(l, "Save events to", "Vista viðburði í") }
    static func createNewCalendar(_ l: Lang) -> String { pick(l, "Create new calendar…", "Búa til nýtt dagatal…") }
    static func newCalendar(_ l: Lang) -> String { pick(l, "New calendar", "Nýtt dagatal") }
    static func newCalendarMessage(_ l: Lang) -> String {
        pick(l,
             "Pick a name for the new iOS calendar Klukk will save sessions to.",
             "Veldu nafn á nýja iOS-dagatalið sem KLUKK vistar lotur í.")
    }
    static func calendarAccessNotGranted(_ l: Lang) -> String {
        pick(l,
             "Calendar access not granted. Allow in Settings → Privacy → Calendars.",
             "Aðgangur að dagatali ekki veittur. Leyfðu í Stillingar → Persónuvernd → Dagatöl.")
    }
    static func couldntCreateCalendar(_ l: Lang) -> String {
        pick(l,
             "Couldn't create calendar. Make sure Klukk has full Calendar access.",
             "Tókst ekki að búa til dagatal. Gættu þess að KLUKK hafi fullan aðgang að dagatali.")
    }

    // MARK: CalendarSheet
    static func noRecordingsYet(_ l: Lang) -> String { pick(l, "No recordings yet", "Engar lotur enn") }
    static func noRecordingsDescription(_ l: Lang) -> String {
        pick(l,
             "Tap the button to start a timer. When you stop, the session lands in your calendar.",
             "Ýttu á hnappinn til að ræsa klukku. Þegar þú stöðvar fer lotan í dagatalið þitt.")
    }
    static func shareAsICS(_ l: Lang) -> String { pick(l, "Share as .ics", "Deila sem .ics") }

    // MARK: DurationPickerSheet
    static func targetSoundHint(_ l: Lang) -> String {
        pick(l,
             "A sound plays when the running timer reaches this.",
             "Hljóð heyrist þegar klukkan nær þessum tíma.")
    }
    static func targetTime(_ l: Lang) -> String { pick(l, "Target time", "Marktími") }
    static func clear(_ l: Lang) -> String { pick(l, "Clear", "Hreinsa") }
    static func set(_ l: Lang) -> String { pick(l, "Set", "Setja") }

    // MARK: LinkCalendarSheet
    static func saveSessionsToCalendar(_ l: Lang) -> String {
        pick(l, "Save your sessions to Calendar", "Vistaðu loturnar þínar í Dagatal")
    }
    static func linkCalendarBody(_ l: Lang) -> String {
        pick(l,
             "KLUKK saves every timed session as an event in your iOS Calendar. Continue to allow Calendar access. You can export any session as .ics, or the whole log as .xml, anytime afterwards.",
             "KLUKK vistar hverja tímamælda lotu sem viðburð í iOS-dagatalinu þínu. Haltu áfram til að leyfa aðgang að dagatali. Þú getur flutt út hvaða lotu sem er sem .ics, eða allan listann sem .xml, hvenær sem er eftir á.")
    }
    static func continueButton(_ l: Lang) -> String { pick(l, "Continue", "Halda áfram") }
    static func linkACalendar(_ l: Lang) -> String { pick(l, "Link a calendar", "Tengja dagatal") }
    static func copyright(_ l: Lang) -> String {
        pick(l, "© NNV ehf. · All rights reserved", "© NNV ehf. · Allur réttur áskilinn")
    }

    // MARK: PresetsView
    static func yourPresets(_ l: Lang) -> String { pick(l, "Your presets", "Forstillingarnar þínar") }
    static func addPreset(_ l: Lang) -> String { pick(l, "Add preset", "Bæta við forstillingu") }
    static func presets(_ l: Lang) -> String { pick(l, "Presets", "Forstillingar") }
    static func presetPlaceholder(_ l: Lang) -> String { pick(l, "e.g. Session {time}", "t.d. Lota {time}") }
    static func tokens(_ l: Lang, _ list: String) -> String {
        pick(l, "Tokens: \(list)", "Tákn: \(list)")
    }
    static func useTokens(_ l: Lang, _ list: String) -> String {
        pick(l, "Use tokens: \(list)", "Notaðu tákn: \(list)")
    }

    // MARK: RenameSheet
    static func title(_ l: Lang) -> String { pick(l, "Title", "Titill") }
    static func discard(_ l: Lang) -> String { pick(l, "Discard", "Henda") }
    static func saveToCalendar(_ l: Lang) -> String { pick(l, "Save to calendar", "Vista í dagatal") }
    static func nameEvent(_ l: Lang) -> String { pick(l, "Name event", "Nefna viðburð") }
    static func preset(_ l: Lang) -> String { pick(l, "Preset", "Forstilling") }

    // MARK: SettingsSheet
    static func settings(_ l: Lang) -> String { pick(l, "Settings", "Stillingar") }
    static func deleteAllConfirm(_ l: Lang) -> String {
        pick(l, "Delete all recorded sessions?", "Eyða öllum skráðum lotum?")
    }
    static func export(_ l: Lang) -> String { pick(l, "Export", "Flytja út") }
    static func exportAllAsXML(_ l: Lang) -> String { pick(l, "Export all as .xml", "Flytja allt út sem .xml") }
    static func exportFooter(_ l: Lang) -> String {
        pick(l,
             "Every session is saved to your calendar. Export the whole log as .xml, or share a single session as .ics from the calendar list.",
             "Hver lota er vistuð í dagatalið þitt. Flyttu allan listann út sem .xml, eða deildu einstakri lotu sem .ics úr dagatalslistanum.")
    }
    static func naming(_ l: Lang) -> String { pick(l, "Naming", "Nafngift") }
    static func titleTemplate(_ l: Lang) -> String { pick(l, "Title template", "Titilsnið") }
    static func custom(_ l: Lang) -> String { pick(l, "Custom", "Sérsniðið") }
    static func askToRename(_ l: Lang) -> String {
        pick(l, "Ask to rename after stop", "Spyrja um endurnefningu eftir stöðvun")
    }
    static func behavior(_ l: Lang) -> String { pick(l, "Behavior", "Hegðun") }
    static func showCentiseconds(_ l: Lang) -> String {
        pick(l, "Show centiseconds", "Sýna hundraðshluta úr sekúndu")
    }
    static func hapticOnStartStop(_ l: Lang) -> String {
        pick(l, "Haptic on start/stop", "Titringur við ræsingu/stöðvun")
    }
    static func appearance(_ l: Lang) -> String { pick(l, "Appearance", "Útlit") }
    static func system(_ l: Lang) -> String { pick(l, "System", "Kerfi") }
    static func light(_ l: Lang) -> String { pick(l, "Light", "Ljóst") }
    static func dark(_ l: Lang) -> String { pick(l, "Dark", "Dökkt") }
    static func clearAllRecordings(_ l: Lang) -> String { pick(l, "Clear all recordings", "Hreinsa allar lotur") }
    static func language(_ l: Lang) -> String { pick(l, "Language", "Tungumál") }

    // MARK: StopwatchView
    static func startTiming(_ l: Lang) -> String { pick(l, "Start timing", "Hefja tímamælingu") }
    static func stopAndSave(_ l: Lang) -> String { pick(l, "Stop and save to calendar", "Stöðva og vista í dagatal") }
    static func notLinked(_ l: Lang) -> String { pick(l, "Not linked", "Ekki tengt") }
    static func showsYourSessions(_ l: Lang) -> String {
        pick(l, "Shows your recorded sessions", "Sýnir skráðu loturnar þínar")
    }
    static func chooseDestination(_ l: Lang) -> String {
        pick(l, "Choose where recordings are sent", "Veldu hvert lotur eru sendar")
    }
    static func calendarA11y(_ l: Lang, _ name: String) -> String {
        pick(l, "Calendar: \(name)", "Dagatal: \(name)")
    }
    static func allowAccessInSettings(_ l: Lang) -> String {
        pick(l, "Allow Calendar access in Settings", "Leyfðu aðgang að dagatali í Stillingum")
    }
    static func savedTo(_ l: Lang, _ name: String) -> String {
        pick(l, "Saved · \(name)", "Vistað · \(name)")
    }
    static func couldntSave(_ l: Lang) -> String {
        pick(l, "Couldn't save to Calendar", "Tókst ekki að vista í Dagatal")
    }
    static func linkedTo(_ l: Lang, _ name: String) -> String {
        pick(l, "Linked · \(name)", "Tengt · \(name)")
    }

    // MARK: TimerAlarm (notification)
    static func targetReached(_ l: Lang) -> String { pick(l, "Target reached.", "Marktíma náð.") }

    // MARK: Format
    static func today(_ l: Lang) -> String { pick(l, "Today", "Í dag") }
    static func yesterday(_ l: Lang) -> String { pick(l, "Yesterday", "Í gær") }

    // MARK: Widget
    static func todayCount(_ l: Lang, _ count: Int) -> String {
        if l == .en {
            return "today · \(count) session\(count == 1 ? "" : "s")"
        } else {
            return "í dag · \(count) \(count == 1 ? "lota" : "lotur")"
        }
    }
    static func noSessionsTapButton(_ l: Lang) -> String {
        pick(l, "No sessions yet — tap the button.", "Engar lotur enn — ýttu á hnappinn.")
    }
    static func widgetDescription(_ l: Lang) -> String {
        pick(l,
             "Tap the pink button to start and stop. Sessions land in your calendar.",
             "Ýttu á bleika hnappinn til að ræsa og stöðva. Lotur fara í dagatalið þitt.")
    }
}
