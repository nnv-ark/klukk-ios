import Foundation
import UserNotifications

/// Schedules the "target reached" alert as a local notification, so it fires whether
/// the app is foreground or the phone is locked. One pending alarm at a time.
@MainActor
final class TimerAlarm: NSObject, UNUserNotificationCenterDelegate {
    static let shared = TimerAlarm()
    private let id = "klukk.target"

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound])) ?? false
    }

    /// Fire `seconds` from now. Replaces any pending alarm.
    func schedule(after seconds: TimeInterval) {
        cancel()
        guard seconds > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "KLUKK!"
        content.body = "Target reached."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        )
    }

    func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    /// Ring (and show) even when the app is in the foreground.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}
