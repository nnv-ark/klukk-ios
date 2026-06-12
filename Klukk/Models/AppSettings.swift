import Foundation
import Observation

@MainActor
@Observable
final class AppSettings {
    var target: CalendarTarget = .ios
    var titleTemplate: String = "Session {time}"
    var confirmRename: Bool = false
    var showCentiseconds: Bool = true
    var haptic: Bool = true
    var hasLinkedCalendar: Bool = false
    var selectedCalendarID: String? = nil

    private static let key = "klukk.settings.v1"

    static func load() -> AppSettings {
        // One-time migration: pre-1.1 builds stored settings in standard defaults,
        // which the widget can't read.
        if AppGroup.defaults.data(forKey: key) == nil,
           let legacy = UserDefaults.standard.data(forKey: key) {
            AppGroup.defaults.set(legacy, forKey: key)
        }
        guard let data = AppGroup.defaults.data(forKey: key),
              let dto = try? JSONDecoder().decode(SettingsDTO.self, from: data) else {
            return AppSettings()
        }
        let s = AppSettings()
        s.target = dto.target
        s.titleTemplate = dto.titleTemplate
        s.confirmRename = dto.confirmRename
        s.showCentiseconds = dto.showCentiseconds
        s.haptic = dto.haptic
        s.hasLinkedCalendar = dto.hasLinkedCalendar
        s.selectedCalendarID = dto.selectedCalendarID
        return s
    }

    func save() {
        let dto = SettingsDTO(
            target: target,
            titleTemplate: titleTemplate,
            confirmRename: confirmRename,
            showCentiseconds: showCentiseconds,
            haptic: haptic,
            hasLinkedCalendar: hasLinkedCalendar,
            selectedCalendarID: selectedCalendarID
        )
        if let data = try? JSONEncoder().encode(dto) {
            AppGroup.defaults.set(data, forKey: Self.key)
        }
    }
}

private struct SettingsDTO: Codable {
    var target: CalendarTarget
    var titleTemplate: String
    var confirmRename: Bool
    var showCentiseconds: Bool
    var haptic: Bool
    var hasLinkedCalendar: Bool
    var selectedCalendarID: String?
}
