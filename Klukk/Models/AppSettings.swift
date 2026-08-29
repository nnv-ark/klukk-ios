import Foundation
import Observation

enum AppAppearance: String, Codable, CaseIterable {
    case system, light, dark
}

@MainActor
@Observable
final class AppSettings {
    var appearance: AppAppearance = .system
    var language: AppLanguage = .system
    var titleTemplate: String = AppSettings.defaultTemplate(Localization.stored)
    var titlePresets: [String] = AppSettings.defaultPresets(Localization.stored)
    var presetsSeed: Int = AppSettings.currentPresetsSeed
    var confirmRename: Bool = false
    var showCentiseconds: Bool = true
    var haptic: Bool = true
    var hasLinkedCalendar: Bool = false
    var hasOnboarded: Bool = false
    var selectedCalendarID: String? = nil
    var selectedCalendarName: String? = nil
    var targetSeconds: TimeInterval? = nil

    /// The default session-name template for a fresh install, in the user's language.
    static func defaultTemplate(_ lang: Lang) -> String {
        lang == .is_ ? "Lota {time}" : "Session {time}"
    }
    /// Starter title presets for a fresh install (and seed top-ups), in the user's language.
    static func defaultPresets(_ lang: Lang) -> [String] {
        lang == .is_
            ? ["Lota {time}", "{date} {time}", "Einbeiting {n}", "Vinna", "Hugleiðsla", "Æfing"]
            : ["Session {time}", "{date} {time}", "Focus {n}", "Work", "Meditation", "Workout"]
    }
    /// Bump when adding new default presets; existing users get the new ones topped up
    /// once (deletions afterwards stick). Seed 3 = language-aware starter presets.
    static let currentPresetsSeed = 3
    /// Tokens that expand when a session is named. Shown wherever a template is edited.
    static let templateTokens = "{time} {date} {n} {duration}"

    /// The concrete language to render in, resolving `.system` against the device
    /// locale. Reading this inside a view's `body` makes the view re-render when
    /// the language switch changes, so the UI flips without a restart.
    var lang: Lang { Localization.resolve(language) }

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
        s.language = dto.language ?? .system
        s.titleTemplate = dto.titleTemplate
        s.titlePresets = dto.titlePresets ?? Self.defaultPresets(s.lang)
        // Top up newly-added default presets once for existing users; deletions stick.
        if (dto.presetsSeed ?? 1) < Self.currentPresetsSeed {
            for preset in Self.defaultPresets(s.lang) where !s.titlePresets.contains(preset) {
                s.titlePresets.append(preset)
            }
        }
        s.presetsSeed = Self.currentPresetsSeed
        s.confirmRename = dto.confirmRename
        s.showCentiseconds = dto.showCentiseconds
        s.haptic = dto.haptic
        s.hasLinkedCalendar = dto.hasLinkedCalendar
        // Pre-1.1.1 users have no flag; if they already linked, they've onboarded.
        s.hasOnboarded = dto.hasOnboarded ?? dto.hasLinkedCalendar
        s.selectedCalendarID = dto.selectedCalendarID
        s.selectedCalendarName = dto.selectedCalendarName
        s.targetSeconds = dto.targetSeconds
        return s
    }

    func save() {
        let dto = SettingsDTO(
            appearance: appearance,
            language: language,
            titleTemplate: titleTemplate,
            titlePresets: titlePresets,
            presetsSeed: presetsSeed,
            confirmRename: confirmRename,
            showCentiseconds: showCentiseconds,
            haptic: haptic,
            hasLinkedCalendar: hasLinkedCalendar,
            hasOnboarded: hasOnboarded,
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
    var language: AppLanguage?       // optional so pre-language settings still decode
    var titleTemplate: String
    var titlePresets: [String]?   // optional so pre-1.1 settings still decode
    var presetsSeed: Int?         // tracks which default-preset batch was seeded
    var confirmRename: Bool
    var showCentiseconds: Bool
    var haptic: Bool
    var hasLinkedCalendar: Bool
    var hasOnboarded: Bool?
    var selectedCalendarID: String?
    var selectedCalendarName: String?
    var targetSeconds: TimeInterval?
}
