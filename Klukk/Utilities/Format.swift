import Foundation

enum Format {
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

    static func durationLong(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 { return "\(h)h \(m)m \(s)s" }
        if m > 0 { return "\(m)m \(s)s" }
        return "\(s)s"
    }

    static let timeOfDay: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    static func dayLabel(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Today" }
        if cal.isDateInYesterday(date) { return "Yesterday" }
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: date)
    }

    static func renderTitle(_ template: String, session: Session, index: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return template
            .replacingOccurrences(of: "{time}", with: timeOfDay.string(from: session.startedAt))
            .replacingOccurrences(of: "{date}", with: dateFormatter.string(from: session.startedAt))
            .replacingOccurrences(of: "{n}", with: String(index))
            .replacingOccurrences(of: "{duration}", with: durationLong(session.duration))
    }
}
