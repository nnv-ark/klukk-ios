import Foundation

/// The shared container both the app and the widget extension read and write.
enum AppGroup {
    static let id = "group.ehf.nnv.klukk"

    static var container: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static var defaults: UserDefaults {
        UserDefaults(suiteName: id) ?? .standard
    }
}
