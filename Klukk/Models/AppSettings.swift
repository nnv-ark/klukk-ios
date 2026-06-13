import Foundation
import Observation

enum AppAppearance: String, Codable, CaseIterable {
    case system, light, dark
}

@MainActor
@Observable
final class AppSettings {
    var appearance: AppAppearance = .system
    var titleTemplate: String = "Session {time}"
    var titlePresets: [String] = AppSettings.defaultPresets
    var presetsSeed: Int = AppSettings.currentPresetsSeed
    var confirmRename: Bool = false
    var showCentiseconds: Bool = true
    var haptic: Bool = true
    var hasLinkedCalendar: Bool = false
    var selectedCalendarID: String? = nil
    var selectedCalendarName: String? = nil
    var targetSeconds: TimeInterval? = nil

    static let defaultPresets = [
        "Session {time}", "{date} {time}", "Focus {n}",
        "Work", "Meditation", "Workout"
    ]
    /// Bump when adding new default presets; existing users get the new ones topped up
    /// once (deletions afterwards stick).
    static let currentPresetsSeed = 2
    /// Tokens that expand when a session is named. Shown wherever a template is edited.
    static let templateTokens = "{time} {date} {n} {duration}"

    private static let key = "klukk.settings.v1"

    func addPreset(_ template: String) {
        let trimmed = template.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !titlePresets.contains(trimmed) else { return }
        titlePresets.append(trimmed)
        save()
    }

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
        s.appearance = dto.appearance ?? .system
        s.titleTemplate = dto.titleTemplate
        s.titlePresets = dto.titlePresets ?? Self.defaultPresets
        // Top up newly-added default presets once for existing users; deletions stick.
        if (dto.presetsSeed ?? 1) < Self.currentPresetsSeed {
            for preset in Self.defaultPresets where !s.titlePresets.contains(preset) {
                s.titlePresets.append(preset)
            }
        }
        s.presetsSeed = Self.currentPresetsSeed
        s.confirmRename = dto.confirmRename
        s.showCentiseconds = dto.showCentiseconds
        s.haptic = dto.haptic
        s.hasLinkedCalendar = dto.hasLinkedCalendar
        s.selectedCalendarID = dto.selectedCalendarID
        s.selectedCalendarName = dto.selectedCalendarName
        s.targetSeconds = dto.targetSeconds
        return s
    }

    func save() {
        let dto = SettingsDTO(
            appearance: appearance,
            titleTemplate: titleTemplate,
            titlePresets: titlePresets,
            presetsSeed: presetsSeed,
            confirmRename: confirmRename,
            showCentiseconds: showCentiseconds,
            haptic: haptic,
            hasLinkedCalendar: hasLinkedCalendar,
            selectedCalendarID: selectedCalendarID,
            selectedCalendarName: selectedCalendarName,
            targetSeconds: targetSeconds
        )
        if let data = try? JSONEncoder().encode(dto) {
            AppGroup.defaults.set(data, forKey: Self.key)
        }
    }
}

private struct SettingsDTO: Codable {
    var appearance: AppAppearance?   // optional so pre-toggle settings still decode
    var titleTemplate: String
    var titlePresets: [String]?   // optional so pre-1.1 settings still decode
    var presetsSeed: Int?         // tracks which default-preset batch was seeded
    var confirmRename: Bool
    var showCentiseconds: Bool
    var haptic: Bool
    var hasLinkedCalendar: Bool
    var selectedCalendarID: String?
    var selectedCalendarName: String?
    var targetSeconds: TimeInterval?
}
