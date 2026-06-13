import SwiftUI
import EventKit

struct CalendarPickerView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var calendars: [EKCalendar] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showCreate = false
    @State private var newCalendarName = ""
    @State private var isCreating = false

    var body: some View {
        @Bindable var settings = settings
        Form {
            if isLoading {
                Section {
                    HStack {
                        ProgressView()
                        Text("Loading calendars…").foregroundStyle(.primary)
                    }
                }
            } else if let errorMessage {
                Section {
                    Text(errorMessage).foregroundStyle(.red)
                }
            } else {
                Section("Save events to") {
                    ForEach(calendars, id: \.calendarIdentifier) { cal in
                        Button {
                            settings.selectedCalendarID = cal.calendarIdentifier
                            settings.selectedCalendarName = cal.title
                            settings.save()
                        } label: {
                            HStack {
                                Circle()
                                    .fill(Color(cgColor: cal.cgColor))
                                    .frame(width: 12, height: 12)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(cal.title).foregroundStyle(.primary)
                                    Text(cal.source.title)
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if cal.calendarIdentifier == settings.selectedCalendarID {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                    }
                }
            }

            Section {
                Button {
                    showCreate = true
                } label: {
                    Label("Create new calendar…", systemImage: "plus")
                        .foregroundStyle(.primary)
                }
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .task { await reload() }
        .alert("New calendar", isPresented: $showCreate) {
            TextField("Name", text: $newCalendarName)
            Button("Cancel", role: .cancel) {
                newCalendarName = ""
            }
            Button("Create") {
                Task { await create() }
            }
            .disabled(newCalendarName.trimmingCharacters(in: .whitespaces).isEmpty)
        } message: {
            Text("Pick a name for the new iOS calendar Klukk will save sessions to.")
        }
    }

    private func reload() async {
        isLoading = true
        errorMessage = nil
        do {
            let cals = try await EventKitService.shared.writableCalendars()
            calendars = cals.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
            if settings.selectedCalendarID == nil,
               let defaultCal = EventKitService.shared.store.defaultCalendarForNewEvents {
                settings.selectedCalendarID = defaultCal.calendarIdentifier
                settings.selectedCalendarName = defaultCal.title
                settings.save()
            }
        } catch {
            errorMessage = "Calendar access not granted. Allow in Settings → Privacy → Calendars."
        }
        isLoading = false
    }

    private func create() async {
        let name = newCalendarName.trimmingCharacters(in: .whitespaces)
        newCalendarName = ""
        guard !name.isEmpty else { return }
        isCreating = true
        defer { isCreating = false }
        do {
            let cal = try await EventKitService.shared.createCalendar(named: name)
            @Bindable var settings = settings
            settings.selectedCalendarID = cal.calendarIdentifier
            settings.selectedCalendarName = cal.title
            settings.save()
            await reload()
        } catch {
            errorMessage = "Couldn't create calendar. Make sure Klukk has full Calendar access."
        }
    }
}
