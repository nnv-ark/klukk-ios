import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Bundle

@main
struct KlukkWidgetsBundle: WidgetBundle {
    var body: some Widget {
        KlukkWidget()
    }
}

// MARK: - Intent (Phase 4): the pink button, tappable without opening the app

struct ToggleTimerIntent: AppIntent {
    static let title: LocalizedStringResource = "Start or stop KLUKK"
    static let description = IntentDescription("Starts the stopwatch, or stops it and records the session.")

    func perform() async throws -> some IntentResult {
        if let started = RunningState.startedAt {
            // Stop: record the session; the app delivers it on next launch.
            let ended = Date()
            let settings = SharedSettings.load()
            let provisional = Session(
                title: "", startedAt: started, endedAt: ended,
                pendingDelivery: true
            )
            let title = Format.renderTitle(
                settings.titleTemplate, session: provisional,
                index: SharedStore.load().count + 1
            )
            var session = provisional
            session.title = title
            SharedStore.append(session)
            RunningState.startedAt = nil
        } else {
            RunningState.startedAt = Date()
        }
        return .result()
    }
}

// MARK: - Timeline

struct KlukkEntry: TimelineEntry {
    let date: Date
    let runningSince: Date?
    let todayTotal: TimeInterval
    let todayCount: Int
    let recent: [Session]
}

struct KlukkProvider: TimelineProvider {
    func snapshot() -> KlukkEntry {
        let sessions = SharedStore.load()
        let today = sessions.filter { Calendar.current.isDateInToday($0.startedAt) }
        return KlukkEntry(
            date: .now,
            runningSince: RunningState.startedAt,
            todayTotal: today.reduce(0) { $0 + $1.duration },
            todayCount: today.count,
            recent: Array(sessions.prefix(3))
        )
    }

    func placeholder(in context: Context) -> KlukkEntry {
        KlukkEntry(date: .now, runningSince: nil, todayTotal: 8048, todayCount: 6, recent: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (KlukkEntry) -> Void) {
        completion(snapshot())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<KlukkEntry>) -> Void) {
        // The app and the intent reload timelines on every change; refresh at
        // midnight so "today" rolls over even with no activity.
        let midnight = Calendar.current.startOfDay(for: .now).addingTimeInterval(86_400)
        completion(Timeline(entries: [snapshot()], policy: .after(midnight)))
    }
}

// MARK: - Widget

struct KlukkWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KlukkWidget", provider: KlukkProvider()) { entry in
            KlukkWidgetView(entry: entry)
                .containerBackground(Color(.background), for: .widget)
        }
        .configurationDisplayName("KLUKK!")
        .description("Tap the pink button to start and stop. Sessions land in your calendar.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Views (per approved mock: same bead + type across sizes;
// large = medium header + divider + recent sessions)

struct KlukkWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: KlukkEntry

    var body: some View {
        switch family {
        case .systemSmall:
            bead
        case .systemMedium:
            header
        default:
            VStack(alignment: .leading, spacing: 12) {
                header
                Divider()
                recentList
                Spacer(minLength: 0)
            }
        }
    }

    private var bead: some View {
        Button(intent: ToggleTimerIntent()) {
            Image("KlukkBall")
                .resizable()
                .scaledToFit()
                .shadow(color: .black.opacity(0.25), radius: 8, x: 4, y: 8)
                .overlay {
                    if entry.runningSince != nil {
                        Circle().strokeBorder(.white.opacity(0.55), lineWidth: 3).padding(2)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(entry.runningSince == nil ? "Start timing" : "Stop and save")
    }

    private var header: some View {
        HStack(spacing: 16) {
            bead
            VStack(alignment: .leading, spacing: 4) {
                Text("KLUKK!")
                    .font(.system(size: 13, weight: .heavy))
                timerText
                    .font(.system(size: 30, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text("today · \(entry.todayCount) session\(entry.todayCount == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }

    /// Live count-up while running (system-animated, no battery cost); today's
    /// completed total otherwise.
    @ViewBuilder
    private var timerText: some View {
        if let since = entry.runningSince {
            Text(since, style: .timer)
        } else {
            Text(Format.clock(entry.todayTotal))
        }
    }

    private var recentList: some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(entry.recent) { session in
                HStack {
                    Text(session.title)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                    Spacer()
                    Text(Format.clock(session.duration))
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
            if entry.recent.isEmpty {
                Text("No sessions yet — tap the button.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
