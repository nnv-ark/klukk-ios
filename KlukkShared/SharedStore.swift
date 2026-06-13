import Foundation

/// File-level access to the shared session list. Used by the app's `SessionStore`
/// and by the widget intent, which runs in a separate process.
enum SharedStore {
    static var url: URL { AppGroup.container.appendingPathComponent("klukk-sessions.json") }

    static func load() -> [Session] {
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Session].self, from: data) else { return [] }
        return decoded
    }

    static func save(_ sessions: [Session]) {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        try? data.write(to: url, options: .atomic)
    }

    /// Prepends a session (newest first), mirroring `SessionStore.add`.
    static func append(_ session: Session) {
        var sessions = load()
        sessions.insert(session, at: 0)
        save(sessions)
    }
}

/// The live stopwatch state, persisted to the shared defaults so the widget can
/// render a ticking timer and the app can pick up a widget-started session.
enum RunningState {
    private static let key = "klukk.running.startedAt"

    static var startedAt: Date? {
        get {
            let t = AppGroup.defaults.double(forKey: key)
            return t > 0 ? Date(timeIntervalSince1970: t) : nil
        }
        set {
            if let newValue {
                AppGroup.defaults.set(newValue.timeIntervalSince1970, forKey: key)
            } else {
                AppGroup.defaults.removeObject(forKey: key)
            }
        }
    }
}

/// The subset of the app settings the widget needs. Decodes from the same JSON the
/// app writes (extra keys are ignored by `JSONDecoder`).
struct SharedSettings: Codable {
    var titleTemplate: String = "Session {time}"

    static func load() -> SharedSettings {
        guard let data = AppGroup.defaults.data(forKey: "klukk.settings.v1"),
              let decoded = try? JSONDecoder().decode(SharedSettings.self, from: data) else {
            return SharedSettings()
        }
        return decoded
    }
}
