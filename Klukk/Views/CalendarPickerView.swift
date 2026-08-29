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
                        Text(L.loadingCalendars(settings.lang)).foregroundStyle(.primary)
                    }
                }
            } else if let errorMessage {
                Section {
                    Text(errorMessage).foregroundStyle(.red)
                }
            } else {
                Section(L.saveEventsTo(settings.lang)) {
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
                    Label(L.createNewCalendar(settings.lang), systemImage: "plus")
                        .foregroundStyle(.primary)
                }
            }
        }
        .navigationTitle(L.calendar(settings.lang))
        .navigationBarTitleDisplayMode(.inline)
        .task { await reload() }
        .alert(L.newCalendar(settings.lang), isPresented: $showCreate) {
            TextField(L.name(settings.lang), text: $newCalendarName)
            Button(L.cancel(settings.lang), role: .cancel) {
                newCalendarName = ""
            }
            Button(L.create(settings.lang)) {
                Task { await create() }
            }
            .disabled(newCalendarName.trimmingCharacters(in: .whitespaces).isEmpty)
        } message: {
            Text(L.newCalendarMessage(settings.lang))
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
            errorMessage = L.calendarAccessNotGranted(settings.lang)
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
            errorMessage = L.couldntCreateCalendar(settings.lang)
        }
    }
}
