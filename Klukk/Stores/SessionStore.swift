import Foundation
import Observation
import WidgetKit

@MainActor
@Observable
final class SessionStore {
    var sessions: [Session] = []

    init() {
        migrateFromDocumentsIfNeeded()
        sessions = SharedStore.load()
    }

    /// Pre-1.1 builds stored sessions in the app's Documents directory, which the
    /// widget can't read. Copy that file into the App Group container once.
    private func migrateFromDocumentsIfNeeded() {
        let fm = FileManager.default
        let legacy = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("klukk-sessions.json")
        guard fm.fileExists(atPath: legacy.path),
              !fm.fileExists(atPath: SharedStore.url.path) else { return }
        try? fm.copyItem(at: legacy, to: SharedStore.url)
    }

    /// Re-reads the shared file — e.g. after the widget recorded a session.
    func reload() {
        sessions = SharedStore.load()
    }

    private func persist() {
        SharedStore.save(sessions)
        WidgetCenter.shared.reloadAllTimelines()
    }

    func add(_ session: Session) {
        sessions.insert(session, at: 0)
        persist()
    }

    func markDelivered(_ id: UUID) {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].pendingDelivery = nil
        persist()
    }

    func clear() {
        sessions = []
        persist()
    }
}
