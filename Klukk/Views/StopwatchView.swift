import SwiftUI
import UIKit
import WidgetKit

struct StopwatchView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(SessionStore.self) private var store
    @Environment(\.scenePhase) private var scenePhase

    @State private var isRunning = false
    @State private var startedAt: Date?
    @State private var isPressed = false

    @State private var activeSheet: ActiveSheet?
    @State private var pendingSession: Session?
    @State private var toast: String?

    private let ballSize: CGFloat = 280

    enum ActiveSheet: Identifiable {
        case calendar, settings, rename, link, duration
        var id: Int { hashValue }
    }

    var body: some View {
        @Bindable var settings = settings
        ZStack {
            // ── Background ── warm skin (light) / RAL 8025 brown (dark)
            Color(.background).ignoresSafeArea()

            // ── Pink sphere — geometric center of screen ──
            stopwatchButton

            // ── Timer (tap to set a target) — floats above the sphere ──
            Button {
                activeSheet = .duration
            } label: {
                VStack(spacing: 7) {
                    timerDisplay
                    if let target = settings.targetSeconds {
                        targetChip(target)
                    }
                }
            }
            .buttonStyle(.plain)
            .offset(y: -(ballSize / 2 + 64))

            // ── Header pinned to top ──
            VStack {
                header
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                Spacer()
            }

            // ── Calendar button pinned to bottom ──
            VStack {
                Spacer()
                openCalendarButton
                    .padding(.bottom, 52)
            }

            // ── Toast ──
            if let toast {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.callout.weight(.semibold))
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(.black, in: .capsule)
                        .foregroundStyle(.white)
                        .padding(.bottom, 110)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .allowsHitTesting(false)
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .calendar:
                CalendarSheet()
            case .settings:
                SettingsSheet(onClear: { store.clear() })
            case .rename:
                if let pendingSession {
                    RenameSheet(session: pendingSession) { finalTitle in
                        finalize(pendingSession, renamedTo: finalTitle)
                        self.pendingSession = nil
                        activeSheet = nil
                    } onDiscard: {
                        self.pendingSession = nil
                        activeSheet = nil
                    }
                }
            case .link:
                LinkCalendarSheet {
                    settings.hasLinkedCalendar = true
                    settings.save()
                    showToast("Linked · \(settings.selectedCalendarName ?? "Calendar")")
                    activeSheet = nil
                }
            case .duration:
                DurationPickerSheet(initial: settings.targetSeconds) { newTarget in
                    setTarget(newTarget)
                    activeSheet = nil
                }
            }
        }
        .task {
            _ = TimerAlarm.shared   // register the notification delegate early
            syncWithSharedState()
            await reconcilePendingSessions()
            if !settings.hasLinkedCalendar {
                try? await Task.sleep(for: .milliseconds(400))
                activeSheet = .link
            }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            syncWithSharedState()
            store.reload()
            Task { await reconcilePendingSessions() }
        }
    }

    /// Adopt a timer the widget started (or notice one it stopped) so both
    /// surfaces always agree on the running state.
    private func syncWithSharedState() {
        if let shared = RunningState.startedAt {
            startedAt = shared
            isRunning = true
        } else if isRunning {
            isRunning = false
            startedAt = nil
        }
    }

    /// Deliver sessions the widget recorded while the app wasn't running.
    private func reconcilePendingSessions() async {
        for session in store.sessions where session.pendingDelivery == true {
            await deliver(session)
            store.markDelivered(session.id)
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            Spacer()

            Button {
                activeSheet = .settings
            } label: {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .padding(6)
            }
            .accessibilityLabel("Settings")
        }
    }

    private var timerDisplay: some View {
        TimelineView(.animation(minimumInterval: 0.03, paused: !isRunning)) { context in
            let elapsed = currentElapsed(at: context.date)
            Text(
                settings.showCentiseconds
                ? "\(Format.clock(elapsed)):\(Format.centiseconds(elapsed))"
                : Format.clock(elapsed)
            )
            .font(.system(size: 36, weight: .semibold, design: .monospaced))
            .monospacedDigit()
            .contentTransition(.numericText(countsDown: false))
            .foregroundStyle(.black)
            .padding(.horizontal, 18).padding(.vertical, 10)
            .whiteCard()
            .shadow(color: .black.opacity(0.08), radius: 14, y: 6)
        }
    }

    private var stopwatchButton: some View {
        Button(action: tapButton) {
            ZStack {
                Image("KlukkBall")
                    .resizable()
                    .scaledToFit()
                    // Sphere PNG is already alpha-masked; shadow follows its true silhouette,
                    // falling down & to the right onto the warm background.
                    .shadow(color: .black.opacity(0.32), radius: 26, x: 14, y: 26)
                if isRunning {
                    Circle()
                        .strokeBorder(.white.opacity(0.55), lineWidth: 4)
                        .padding(6)
                }
            }
            .frame(width: ballSize, height: ballSize)
            .scaleEffect(isPressed ? 0.96 : 1)
            .animation(.spring(duration: 0.18, bounce: 0.3), value: isPressed)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(trigger: isRunning) { _, newValue in
            guard settings.haptic else { return nil }
            return newValue ? .impact(weight: .light) : .impact(weight: .medium)
        }
        .accessibilityLabel(isRunning ? "Stop and save to calendar" : "Start timing")
    }

    /// Single calendar entry point: the destination icon + the selected calendar's name.
    /// Opens the session list when linked, or the link sheet when not.
    private var openCalendarButton: some View {
        Button {
            activeSheet = settings.hasLinkedCalendar ? .calendar : .link
        } label: {
            HStack(spacing: 8) {
                Image(systemName: calendarPillIcon)
                Text(calendarPillLabel)
                    .lineLimit(1)
            }
            .font(.callout.weight(.semibold))
            .foregroundStyle(.black)
            .padding(.horizontal, 16).padding(.vertical, 9)
            .background(.white, in: .capsule)
            .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(settings.hasLinkedCalendar ? "Calendar: \(calendarPillLabel)" : "Link a calendar")
        .accessibilityHint(
            settings.hasLinkedCalendar
            ? "Shows your recorded sessions"
            : "Choose where recordings are sent"
        )
    }

    private func targetChip(_ seconds: TimeInterval) -> some View {
        HStack(spacing: 5) {
            Image(systemName: "bell.fill").font(.caption2)
            Text(Format.clock(seconds))
                .font(.caption.monospacedDigit().weight(.semibold))
        }
        .foregroundStyle(.black.opacity(0.65))
        .padding(.horizontal, 10).padding(.vertical, 4)
        .background(.white.opacity(0.7), in: .capsule)
    }

    private func setTarget(_ seconds: TimeInterval?) {
        settings.targetSeconds = seconds
        settings.save()
        guard let seconds else {
            TimerAlarm.shared.cancel()
            return
        }
        Task {
            await TimerAlarm.shared.requestAuthorization()
            if isRunning {
                TimerAlarm.shared.schedule(after: seconds - currentElapsed(at: Date()))
            }
        }
    }

    private var calendarPillIcon: String {
        settings.hasLinkedCalendar ? "calendar" : "calendar.badge.exclamationmark"
    }

    private var calendarPillLabel: String {
        guard settings.hasLinkedCalendar else { return "Not linked" }
        return settings.selectedCalendarName ?? "Calendar"
    }

    // MARK: - Computed

    private func currentElapsed(at date: Date) -> TimeInterval {
        guard let startedAt, isRunning else { return 0 }
        return date.timeIntervalSince(startedAt)
    }

    // MARK: - Actions

    private func tapButton() {
        SoundPlayer.shared.tap()
        flashPress()

        if isRunning {
            let session = stopTimer()
            if settings.confirmRename {
                pendingSession = session
                activeSheet = .rename
            } else {
                finalize(session)
            }
        } else if settings.hasLinkedCalendar {
            startTimer()
        } else {
            activeSheet = .link
        }
    }

    private func flashPress() {
        isPressed = true
        Task {
            try? await Task.sleep(for: .milliseconds(140))
            isPressed = false
        }
    }

    private func startTimer() {
        startedAt = Date()
        isRunning = true
        RunningState.startedAt = startedAt
        if let target = settings.targetSeconds {
            Task { await TimerAlarm.shared.requestAuthorization() }
            TimerAlarm.shared.schedule(after: target)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Stops the clock and returns the named, but not-yet-delivered, session.
    private func stopTimer() -> Session {
        let ended = Date()
        let started = startedAt ?? ended
        isRunning = false
        startedAt = nil
        RunningState.startedAt = nil
        TimerAlarm.shared.cancel()
        WidgetCenter.shared.reloadAllTimelines()

        var session = Session(title: "", startedAt: started, endedAt: ended)
        session.title = Format.renderTitle(settings.titleTemplate, session: session, index: store.sessions.count + 1)
        return session
    }

    private func finalize(_ session: Session, renamedTo title: String? = nil) {
        var session = session
        if let title { session.title = title }
        store.add(session)
        Task { await deliver(session) }
    }

    /// Every session is written to the iOS Calendar. .ics / .xml are export actions
    /// available later from the session list.
    private func deliver(_ session: Session) async {
        do {
            try await EventKitService.shared.save(session, calendarID: settings.selectedCalendarID)
            showToast("Saved · \(settings.selectedCalendarName ?? "Calendar")")
        } catch {
            showToast("Couldn't save to Calendar")
        }
    }

    private func showToast(_ message: String) {
        withAnimation(.easeOut(duration: 0.2)) { toast = message }
        Task {
            try? await Task.sleep(for: .seconds(2.2))
            withAnimation(.easeIn(duration: 0.2)) { toast = nil }
        }
    }
}

#Preview {
    StopwatchView()
        .environment(AppSettings())
        .environment(SessionStore())
}
