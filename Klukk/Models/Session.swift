import Foundation

struct Session: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var startedAt: Date
    var endedAt: Date
    var target: CalendarTarget

    var duration: TimeInterval { endedAt.timeIntervalSince(startedAt) }
}

enum CalendarTarget: String, Codable, CaseIterable, Identifiable {
    case ios
    case ics
    case xml

    var id: String { rawValue }

    var label: String {
        switch self {
        case .ios: "iOS Calendar"
        case .ics: "Share as .ics"
        case .xml: ".xml document"
        }
    }
}
