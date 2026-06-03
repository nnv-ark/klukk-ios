import Foundation
import Observation

@Observable
final class SessionStore {
    var sessions: [Session] = []

    private let url: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        url = docs.appendingPathComponent("klukk-sessions.json")
        load()
    }

    private func load() {
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Session].self, from: data) else { return }
        sessions = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        try? data.write(to: url, options: .atomic)
    }

    func add(_ session: Session) {
        sessions.insert(session, at: 0)
        persist()
    }

    func clear() {
        sessions = []
        persist()
    }
}
