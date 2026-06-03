import EventKit
import Foundation

@MainActor
final class EventKitService {
    static let shared = EventKitService()
    let store = EKEventStore()

    func requestAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await store.requestFullAccessToEvents()
        } else {
            return try await store.requestAccess(to: .event)
        }
    }

    func writableCalendars() async throws -> [EKCalendar] {
        let granted = try await requestAccess()
        guard granted else { throw EventKitError.notAuthorized }
        return store.calendars(for: .event).filter { $0.allowsContentModifications }
    }

    func calendar(withID id: String?) -> EKCalendar? {
        guard let id else { return nil }
        return store.calendar(withIdentifier: id)
    }

    @discardableResult
    func createCalendar(named title: String) async throws -> EKCalendar {
        let granted = try await requestAccess()
        guard granted else { throw EventKitError.notAuthorized }
        let calendar = EKCalendar(for: .event, eventStore: store)
        calendar.title = title
        calendar.cgColor = CGColor(red: 0.81, green: 0.77, blue: 0.30, alpha: 1)
        calendar.source = preferredSource()
        try store.saveCalendar(calendar, commit: true)
        return calendar
    }

    func save(_ session: Session, calendarID: String?) async throws {
        let granted = try await requestAccess()
        guard granted else { throw EventKitError.notAuthorized }
        let event = EKEvent(eventStore: store)
        event.title = session.title
        event.startDate = session.startedAt
        event.endDate = session.endedAt
        event.calendar = calendar(withID: calendarID) ?? store.defaultCalendarForNewEvents
        try store.save(event, span: .thisEvent)
    }

    private func preferredSource() -> EKSource? {
        if let iCloud = store.sources.first(where: { $0.sourceType == .calDAV && $0.title.lowercased().contains("icloud") }) {
            return iCloud
        }
        if let calDAV = store.sources.first(where: { $0.sourceType == .calDAV }) {
            return calDAV
        }
        if let local = store.sources.first(where: { $0.sourceType == .local }) {
            return local
        }
        return store.defaultCalendarForNewEvents?.source ?? store.sources.first
    }
}

enum EventKitError: Error {
    case notAuthorized
}
