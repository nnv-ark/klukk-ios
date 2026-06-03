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
        }
    }
}
