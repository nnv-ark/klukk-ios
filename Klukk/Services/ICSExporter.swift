import Foundation

enum ICSExporter {
    static func makeFile(for session: Session) throws -> URL {
        let ics = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//NNV ehf.//Klukk//EN
        BEGIN:VEVENT
        UID:\(session.id.uuidString)@klukk.nnv.ehf
        DTSTAMP:\(icsDate(Date()))
        DTSTART:\(icsDate(session.startedAt))
        DTEND:\(icsDate(session.endedAt))
        SUMMARY:\(escape(session.title))
        END:VEVENT
        END:VCALENDAR
        """
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent("klukk-\(session.id.uuidString).ics")
        try ics.data(using: .utf8)?.write(to: url, options: .atomic)
        return url
    }

    private static func icsDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return f.string(from: date)
    }

    private static func escape(_ s: String) -> String {
        s.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}
