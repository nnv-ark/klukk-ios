import SwiftUI
import EventKit

struct RenameSheet: View {
    @Environment(AppSettings.self) private var settings
    @Environment(SessionStore.self) private var store

    let session: Session
    let onSave: (String) -> Void
    let onDiscard: () -> Void

    @State private var title: String
    @State private var calendars: [EKCalendar] = []
    @State private var chosenCalendarID: String?
    @State private var chosenCalendarName: String?

    init(session: Session, onSave: @escaping (String) -> Void, onDiscard: @escaping () -> Void) {
        self.session = session
        self.onSave = onSave
        self.onDiscard = onDiscard
        _title = State(initialValue: session.title)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("\(Format.timeOfDay(session.startedAt, settings.lang)) · \(Format.durationLong(session.duration, settings.lang))")
                    .font(.caption).foregroundStyle(.secondary)

                TextField(L.title(settings.lang), text: $title)
                    .textFieldStyle(.plain)
                    .font(.title3.weight(.semibold))
                    .padding(14)
                    .whiteCard()

                HStack(spacing: 10) {
                    presetMenu
                    calendarMenu
                }

                HStack(spacing: 10) {
                    Button(role: .cancel) {
                        onDiscard()
                    } label: {
                        Text(L.discard(settings.lang))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundStyle(.black)
                    }
                    .whiteCard()

                    Button(action: save) {
                        Text(L.saveToCalendar(settings.lang))
                            .font(.body.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .background(Color.yellow, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.black)
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle(L.nameEvent(settings.lang))
            .navigationBarTitleDisplayMode(.inline)
            .task {
                chosenCalendarID = settings.selectedCalendarID
                chosenCalendarName = settings.selectedCalendarName
                calendars = (try? await EventKitService.shared.writableCalendars())?
                    .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending } ?? []
            }
        }
    }

    // MARK: - Minimal dropdown menus

    private var presetMenu: some View {
        Menu {
            ForEach(settings.titlePresets, id: \.self) { preset in
                Button(preset) {
                    title = Format.renderTitle(preset, session: session, index: store.sessions.count + 1, lang: settings.lang)
                }
            }
        } label: {
            menuLabel(systemImage: "textformat", text: L.preset(settings.lang))
        }
        .disabled(settings.titlePresets.isEmpty)
    }

    private var calendarMenu: some View {
        Menu {
            ForEach(calendars, id: \.calendarIdentifier) { cal in
                Button {
                    chosenCalendarID = cal.calendarIdentifier
                    chosenCalendarName = cal.title
                } label: {
                    if cal.calendarIdentifier == chosenCalendarID {
                        Label(cal.title, systemImage: "checkmark")
                    } else {
                        Text(cal.title)
                    }
                }
            }
        } label: {
            menuLabel(systemImage: "calendar", text: chosenCalendarName ?? L.calendar(settings.lang))
        }
        .disabled(calendars.isEmpty)
    }

    private func menuLabel(systemImage: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            Text(text).lineLimit(1)
            Spacer(minLength: 2)
            Image(systemName: "chevron.down").font(.caption2).foregroundStyle(.secondary)
        }
        .font(.subheadline.weight(.medium))
        .padding(.horizontal, 14).padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground), in: .capsule)
    }

    private func save() {
        if let id = chosenCalendarID {
            settings.selectedCalendarID = id
            settings.selectedCalendarName = chosenCalendarName
            settings.save()
        }
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        onSave(trimmed.isEmpty ? session.title : trimmed)
    }
}
