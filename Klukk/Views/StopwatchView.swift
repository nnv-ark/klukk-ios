import SwiftUI
import UIKit

struct StopwatchView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(SessionStore.self) private var store

    @State private var isRunning = false
    @State private var startedAt: Date?
    @State private var pressed = false

    @State private var activeSheet: ActiveSheet?
    @State private var pendingSession: Session?
    @State private var toast: String?
    @State private var shareURL: URL?

    private let ballSize: CGFloat = 280

    enum ActiveSheet: Identifiable {
        case calendar, settings, rename, link, share
        var id: Int { hashValue }
    }

    var body: some View {
        @Bindable var settings = settings
        ZStack {
            // ── Background ── warm skin (light) / RAL 8025 brown (dark)
            Color("Background").ignoresSafeArea()

            // ── Pink sphere — geometric center of screen ──
            stopwatchButton

            // ── Timer: floats above the sphere ──
            timerDisplay
                .offset(y: -(ballSize / 2 + 56))

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
                        finalize(session: pendingSession, title: finalTitle)
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
                    showToast("Linked · \(settings.target.label)")
                    activeSheet = nil
                }
            case .share:
                if let shareURL { ShareSheet(url: shareURL) }
            }
        }
        .task {
            if !settings.hasLinkedCalendar {
                try? await Task.sleep(for: .milliseconds(400))
                activeSheet = .link
            }
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
            .background(.white, in: RoundedRectangle(cornerRadius: 14))
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
            .scaleEffect(pressed ? 0.96 : 1)
            .animation(.spring(duration: 0.18, bounce: 0.3), value: pressed)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(trigger: isRunning) { _, newValue in
            guard settings.haptic else { return nil }
            return newValue ? .impact(weight: .light) : .impact(weight: .medium)
        }
        .accessibilityLabel(isRunning ? "Stop and save to calendar" : "Start timing")
    }

    /// Single calendar entry point. Shows the active destination (dot + label) and the
    /// session count; opens the session list when linked, or the link sheet when not.
    private var openCalendarButton: some View {
        Button {
            activeSheet = settings.hasLinkedCalendar ? .calendar : .link
        } label: {
            HStack(spacing: 9) {
                Circle()
                    .fill(linkedDotColor)
                    .frame(width: 8, height: 8)
                Text(linkedLabel)
                if !store.sessions.isEmpty {
                    Text("\(store.sessions.count)")
                        .font(.caption.monospacedDigit().weight(.bold))
                        .contentTransition(.numericText())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7).padding(.vertical, 2)
                        .background(.black, in: .capsule)
                }
            }
            .font(.callout.weight(.semibold))
            .foregroundStyle(.black)
            .padding(.horizontal, 16).padding(.vertical, 9)
            .background(.white, in: .capsule)
            .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Computed

    private func currentElapsed(at date: Date) -> TimeInterval {
        guard let startedAt, isRunning else { return 0 }
        return date.timeIntervalSince(startedAt)
    }

    private var linkedDotColor: Color {
        guard settings.hasLinkedCalendar else { return .red }
        return switch settings.target {
        case .ios: .red
        case .ics: .blue
        case .xml: .gray
        }
    }

    private var linkedLabel: String {
        if !settings.hasLinkedCalendar { return "Not linked" }
        return settings.target.label
    }

    // MARK: - Actions

    private func tapButton() {
        SoundPlayer.shared.tap()
        pressed = true
        Task {
            try? await Task.sleep(for: .milliseconds(140))
            pressed = false
        }

        if !isRunning {
            if !settings.hasLinkedCalendar {
                activeSheet = .link
                return
            }
            startedAt = Date()
            isRunning = true
        } else {
            let ended = Date()
            guard let started = startedAt else { return }
            isRunning = false
            startedAt = nil
            let provisional = Session(title: "", startedAt: started, endedAt: ended, target: settings.target)
            let title = Format.renderTitle(settings.titleTemplate, session: provisional, index: store.sessions.count + 1)
            let session = Session(id: provisional.id, title: title, startedAt: started, endedAt: ended, target: settings.target)
            if settings.confirmRename {
                pendingSession = session
                activeSheet = .rename
            } else {
                finalize(session: session, title: title)
            }
        }
    }

    private func finalize(session: Session, title: String) {
        var finalSession = session
        finalSession.title = title
        store.add(finalSession)
        Task { await deliver(finalSession) }
    }

    private func deliver(_ session: Session) async {
        switch session.target {
        case .ios:
            do {
                try await EventKitService.shared.save(session, calendarID: settings.selectedCalendarID)
                showToast("Saved · iOS Calendar")
            } catch {
                showToast("Couldn't save to Calendar")
            }
        case .ics:
            if let url = try? ICSExporter.makeFile(for: session) {
                shareURL = url
                activeSheet = .share
            }
        case .xml:
            try? XMLExporter.append(session)
            showToast("Appended · .xml")
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
