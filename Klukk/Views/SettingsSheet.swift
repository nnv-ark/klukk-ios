import SwiftUI

struct SettingsSheet: View {
    @Environment(AppSettings.self) private var settings
    @Environment(SessionStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let onClear: () -> Void

    @State private var confirmClear = false
    @State private var xmlExport: ShareableURL?

    var body: some View {
        NavigationStack {
            Form {
                calendarSection
                exportSection
                namingSection
                behaviorSection
                appearanceSection
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
            .onChange(of: settings.titleTemplate) { _, _ in settings.save() }
            .onChange(of: settings.confirmRename) { _, _ in settings.save() }
            .onChange(of: settings.showCentiseconds) { _, _ in settings.save() }
            .onChange(of: settings.haptic) { _, _ in settings.save() }
            .onChange(of: settings.appearance) { _, _ in settings.save() }
            .confirmationDialog("Delete all recorded sessions?", isPresented: $confirmClear, titleVisibility: .visible) {
                Button("Delete", role: .destructive) { onClear() }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(item: $xmlExport) { item in
                ShareSheet(url: item.url)
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var calendarSection: some View {
        Section("Calendar") {
            NavigationLink {
                CalendarPickerView()
            } label: {
                HStack {
                    Label("Calendar", systemImage: "calendar")
                    Spacer()
                    Text(settings.selectedCalendarName ?? "Default")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var exportSection: some View {
        Section {
            Button {
                if let url = try? XMLExporter.makeFile(from: store.sessions) {
                    xmlExport = ShareableURL(url: url)
                }
            } label: {
                Label("Export all as .xml", systemImage: "square.and.arrow.up")
            }
            .disabled(store.sessions.isEmpty)
        } header: {
            Text("Export")
        } footer: {
            Text("Every session is saved to your calendar. Export the whole log as .xml, or share a single session as .ics from the calendar list.")
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
                    Text("Presets")
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
    private var appearanceSection: some View {
        @Bindable var settings = settings
        Section("Appearance") {
            Picker("Appearance", selection: $settings.appearance) {
                Text("System").tag(AppAppearance.system)
                Text("Light").tag(AppAppearance.light)
                Text("Dark").tag(AppAppearance.dark)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
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
