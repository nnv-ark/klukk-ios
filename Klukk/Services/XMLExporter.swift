import Foundation

enum XMLExporter {
    static var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("klukk-sessions.xml")
    }

    static func append(_ session: Session) throws {
        var doc = (try? String(contentsOf: fileURL, encoding: .utf8))
            ?? "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<sessions>\n</sessions>\n"
        let entry = """
          <session id="\(session.id.uuidString)">
            <title>\(escape(session.title))</title>
            <startedAt>\(iso(session.startedAt))</startedAt>
            <endedAt>\(iso(session.endedAt))</endedAt>
            <durationSeconds>\(Int(session.duration))</durationSeconds>
          </session>
        """
        doc = doc.replacingOccurrences(of: "</sessions>", with: "\(entry)\n</sessions>")
        try doc.data(using: .utf8)?.write(to: fileURL, options: .atomic)
    }

    private static func iso(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }

    private static func escape(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
