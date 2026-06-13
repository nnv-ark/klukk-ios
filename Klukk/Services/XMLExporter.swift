import Foundation

enum XMLExporter {
    static var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("Klukk.xml")
    }

    /// Writes the whole session log as a fresh .xml document and returns its URL.
    /// The session store is the source of truth — the file is regenerated on each export.
    @discardableResult
    static func makeFile(from sessions: [Session]) throws -> URL {
        let entries = sessions
            .sorted { $0.startedAt > $1.startedAt }
            .map { session in
                """
                  <session id="\(session.id.uuidString)">
                    <title>\(escape(session.title))</title>
                    <startedAt>\(iso(session.startedAt))</startedAt>
                    <endedAt>\(iso(session.endedAt))</endedAt>
                    <durationSeconds>\(Int(session.duration))</durationSeconds>
                  </session>
                """
            }
            .joined(separator: "\n")
        let doc = """
        <?xml version="1.0" encoding="UTF-8"?>
        <sessions>
        \(entries)
        </sessions>
        """
        try doc.data(using: .utf8)?.write(to: fileURL, options: .atomic)
        return fileURL
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
