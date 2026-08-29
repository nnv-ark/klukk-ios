import SwiftUI

@main
struct KlukkApp: App {
    @State private var settings = AppSettings.load()
    @State private var sessionStore = SessionStore()

    var body: some Scene {
        WindowGroup {
            StopwatchView()
                .environment(settings)
                .environment(sessionStore)
                .environment(\.locale, Locale(identifier: settings.lang == .is_ ? "is_IS" : "en_US"))
                .preferredColorScheme(settings.appearance.colorScheme)
        }
    }
}

extension AppAppearance {
    /// nil = follow the system; otherwise force light/dark app-wide.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
