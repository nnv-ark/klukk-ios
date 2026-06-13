import SwiftUI

struct CalendarSheet: View {
    @Environment(SessionStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var share: ShareableURL?

    var body: some View {
        NavigationStack {
            Group {
                if store.sessions.isEmpty {
                    ContentUnavailableView(
                        "No recordings yet",
                        systemImage: "clock.badge.checkmark",
                        description: Text("Tap the button to start a timer. When you stop, the session lands in your calendar.")
                    )
                } else {
                    List {
                        ForEach(grouped, id: \.label) { group in
                            Section(group.label) {
                                ForEach(group.items) { session in
                                    SessionRow(session: session)
                                        .contextMenu {
                                            Button {
                                                shareICS(session)
                                            } label: {
                                                Label("Share as .ics", systemImage: "square.and.arrow.up")
                                            }
                                        }
                                        .swipeActions(edge: .leading) {
                                            Button {
                                                shareICS(session)
                                            } label: {
                                                Label(".ics", systemImage: "square.and.arrow.up")
                                            }
                                            .tint(.blue)
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(item: $share) { item in
                ShareSheet(url: item.url)
            }
        }
    }

    private func shareICS(_ session: Session) {
        if let url = try? ICSExporter.makeFile(for: session) {
            share = ShareableURL(url: url)
        }
    }

    private var grouped: [(label: String, items: [Session])] {
        let groups = Dictionary(grouping: store.sessions) { session in
            Calendar.current.startOfDay(for: session.startedAt)
        }
        return groups
            .sorted { $0.key > $1.key }
            .map { (Format.dayLabel($0.key), $0.value.sorted { $0.startedAt > $1.startedAt }) }
    }
}

private struct SessionRow: View {
    let session: Session

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0.78, green: 0.15, blue: 0.66))
                .frame(width: 4, height: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(session.title).font(.body.weight(.semibold))
                Text(Format.timeOfDay.string(from: session.startedAt))
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(Format.clock(session.duration))
                .font(.callout.monospacedDigit().weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
