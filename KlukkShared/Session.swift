import Foundation

struct Session: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var startedAt: Date
    var endedAt: Date
    /// Set by the widget when it records a session the app hasn't yet written to
    /// the calendar. Optional so pre-1.1 JSON still decodes (nil = delivered).
    var pendingDelivery: Bool? = nil

    var duration: TimeInterval { endedAt.timeIntervalSince(startedAt) }
}
