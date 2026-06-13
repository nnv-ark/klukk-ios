import SwiftUI

struct SettingsSheet: View {
    @Environment(AppSettings.self) private var settings
    @Environment(SessionStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let onClear: () -> Void

    @State private var confirmClear = false
    @State private var xmlFileExists = false
    @State private var showXMLShare = false

    var body: some View {
        @Bindable var settings = settings
        NavigationStack {
            Form {
                destinationSection
                if settings.target == .ios { calendarSection }
                if settings.target == .xml { xmlSection }
                namingSection
                behaviorSection
                clearSection
                footerSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .onChange(of: settings.target) { _, _ in settings.save() }
            .onChange(of: settings.titleTemplate) { _, _ in settings.save() }
            .onChange(of: settings.confirmRename) { _, _ in settings.save() }
            .onChange(of: settings.showCentiseconds) { _, _ in settings.save() }
            .onChange(of: settings.haptic) { _, _ in settings.save() }
            .confirmationDialog("Delete all recorded sessions?", isPresented: $confirmClear, titleVisibility: .visible) {
                Button("Delete", role: .destructive) { onClear() }
                Button("Cancel", role: .cancel) {}
            }
            .task { refreshXMLStatus() }
            .onChange(of: store.sessions.count) { _, _ in refreshXMLStatus() }
            .sheet(isPresented: $showXMLShare) {
                ShareSheet(url: XMLExporter.fileURL)
            }
        }
    }

    // MARK: - XML status

    private var xmlStatusCaption: String {
        guard xmlFileExists else { return "No sessions yet" }
        let count = store.sessions.filter { $0.target == .xml }.count
        return count == 1 ? "1 session recorded" : "\(count) sessions recorded"
    }

    private func refreshXMLStatus() {
        xmlFileExists = FileManager.default.fileExists(atPath: XMLExporter.fileURL.path)
    }

    // MARK: - Sections

    @ViewBuilder
    private var destinationSection: some View {
        @Bindable var settings = settings
        Section("Send recordings to") {
            Picker("Destination", selection: $settings.target) {
                ForEach(CalendarTarget.allCases) { target in
                    Text(target.label).tag(target)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }

    @ViewBuilder
    private var calendarSection: some View {
        Section("iOS Calendar") {
            NavigationLink {
                CalendarPickerView()
            } label: {
                HStack {
                    Text("Calendar")
                    Spacer()
                    Text(settings.selectedCalendarID == nil ? "Default" : "Choose…")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var xmlSection: some View {
        Section("XML file") {
            Button {
                showXMLShare = true
            } label: {
                Label("Share Klukk.xml", systemImage: "square.and.arrow.up")
            }
            .disabled(!xmlFileExists)
            Text(xmlStatusCaption)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var namingSection: some View {
        @Bindable var settings = settings
        Section("Naming") {
            TextField("Title template", text: $settings.titleTemplate)
                .font(.body.monospaced())
            NavigationLink {
                PresetsView()
            } label: {
                HStack {
                    Text("Preset")
                    Spacer()
                    Text(presetTrailingLabel)
                        .foregroundStyle(.secondary)
                }
            }
            Toggle("Ask to rename after stop", isOn: $settings.confirmRename)
        }
    }

    /// Shows the matching preset name, or "Custom" when the template is hand-edited.
    private var presetTrailingLabel: String {
        settings.titlePresets.contains(settings.titleTemplate) ? settings.titleTemplate : "Custom"
    }

    @ViewBuilder
    private var behaviorSection: some View {
        @Bindable var settings = settings
        Section("Behavior") {
            Toggle("Show centiseconds", isOn: $settings.showCentiseconds)
            Toggle("Haptic on start/stop", isOn: $settings.haptic)
        }
    }

    @ViewBuilder
    private var clearSection: some View {
        Section {
            Button("Clear all recordings", role: .destructive) {
                confirmClear = true
            }
        }
    }

    @ViewBuilder
    private var footerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Text("KLUKK").font(.body.weight(.semibold))
                Text("© NNV ehf. · All rights reserved")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
