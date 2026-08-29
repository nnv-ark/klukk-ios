import Foundation

enum Format {
    /// The OS locale matching a resolved language, used to drive date/time formatting.
    private static func locale(_ lang: Lang) -> Locale {
        Locale(identifier: lang == .is_ ? "is_IS" : "en_US")
    }

    static func clock(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    static func centiseconds(_ interval: TimeInterval) -> String {
        let cs = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d", cs)
    }

    static func durationLong(_ interval: TimeInterval, _ lang: Lang = Localization.stored) -> String {
        let total = Int(interval)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        let (hu, mu, su) = lang == .is_ ? ("klst", "mín", "sek") : ("h", "m", "s")
        if h > 0 { return "\(h)\(hu) \(m)\(mu) \(s)\(su)" }
        if m > 0 { return "\(m)\(mu) \(s)\(su)" }
        return "\(s)\(su)"
    }

    /// Time of day, 12-hour for English and 24-hour for Icelandic (locale-driven).
    static func timeOfDay(_ date: Date, _ lang: Lang = Localization.stored) -> String {
        let f = DateFormatter()
        f.locale = locale(lang)
        f.setLocalizedDateFormatFromTemplate("jmm")
        return f.string(from: date)
    }

    static func dayLabel(_ date: Date, _ lang: Lang = Localization.stored) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return L.today(lang) }
        if cal.isDateInYesterday(date) { return L.yesterday(lang) }
        let f = DateFormatter()
        f.locale = locale(lang)
        f.setLocalizedDateFormatFromTemplate("EEEEdMMM")
        return f.string(from: date)
    }

    static func renderTitle(_ template: String, session: Session, index: Int, lang: Lang = Localization.stored) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale(lang)
        dateFormatter.dateStyle = .short
        return template
            .replacingOccurrences(of: "{time}", with: timeOfDay(session.startedAt, lang))
            .replacingOccurrences(of: "{date}", with: dateFormatter.string(from: session.startedAt))
            .replacingOccurrences(of: "{n}", with: String(index))
            .replacingOccurrences(of: "{duration}", with: durationLong(session.duration, lang))
    }
}
