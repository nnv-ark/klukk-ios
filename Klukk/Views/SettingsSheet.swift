import SwiftUI
import WidgetKit

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
                languageSection
                clearSection
                footerSection
            }
            .navigationTitle(L.settings(settings.lang))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L.close(settings.lang)) { dismiss() }
                }
            }
            .onChange(of: settings.titleTemplate) { _, _ in settings.save() }
            .onChange(of: settings.confirmRename) { _, _ in settings.save() }
            .onChange(of: settings.showCentiseconds) { _, _ in settings.save() }
            .onChange(of: settings.haptic) { _, _ in settings.save() }
            .onChange(of: settings.appearance) { _, _ in settings.save() }
            .onChange(of: settings.language) { _, _ in
                settings.save()
                // The widget reads the language from the shared defaults; refresh it now.
                WidgetCenter.shared.reloadAllTimelines()
            }
            .confirmationDialog(L.deleteAllConfirm(settings.lang), isPresented: $confirmClear, titleVisibility: .visible) {
                Button(L.delete(settings.lang), role: .destructive) { onClear() }
                Button(L.cancel(settings.lang), role: .cancel) {}
            }
            .sheet(item: $xmlExport) { item in
                ShareSheet(url: item.url)
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var calendarSection: some View {
        Section(L.calendar(settings.lang)) {
            NavigationLink {
                CalendarPickerView()
            } label: {
                HStack {
                    Label(L.calendar(settings.lang), systemImage: "calendar")
                    Spacer()
                    Text(settings.selectedCalendarName ?? L.defaultCalendar(settings.lang))
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
                Label(L.exportAllAsXML(settings.lang), systemImage: "square.and.arrow.up")
            }
            .disabled(store.sessions.isEmpty)
        } header: {
            Text(L.export(settings.lang))
        } footer: {
            Text(L.exportFooter(settings.lang))
        }
    }

    @ViewBuilder
    private var namingSection: some View {
        @Bindable var settings = settings
        Section(L.naming(settings.lang)) {
            TextField(L.titleTemplate(settings.lang), text: $settings.titleTemplate)
                .font(.body.monospaced())
            NavigationLink {
                PresetsView()
            } label: {
                HStack {
                    Text(L.presets(settings.lang))
                    Spacer()
                    Text(presetTrailingLabel)
                        .foregroundStyle(.secondary)
                }
            }
            Toggle(L.askToRename(settings.lang), isOn: $settings.confirmRename)
        }
    }

    /// Shows the matching preset name, or "Custom" when the template is hand-edited.
    private var presetTrailingLabel: String {
        settings.titlePresets.contains(settings.titleTemplate) ? settings.titleTemplate : L.custom(settings.lang)
    }

    @ViewBuilder
    private var behaviorSection: some View {
        @Bindable var settings = settings
        Section(L.behavior(settings.lang)) {
            Toggle(L.showCentiseconds(settings.lang), isOn: $settings.showCentiseconds)
            Toggle(L.hapticOnStartStop(settings.lang), isOn: $settings.haptic)
        }
    }

    @ViewBuilder
    private var appearanceSection: some View {
        @Bindable var settings = settings
        Section(L.appearance(settings.lang)) {
            Picker(L.appearance(settings.lang), selection: $settings.appearance) {
                Text(L.system(settings.lang)).tag(AppAppearance.system)
                Text(L.light(settings.lang)).tag(AppAppearance.light)
                Text(L.dark(settings.lang)).tag(AppAppearance.dark)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }

    @ViewBuilder
    private var languageSection: some View {
        @Bindable var settings = settings
        Section(L.language(settings.lang)) {
            Picker(L.language(settings.lang), selection: $settings.language) {
                Text(L.system(settings.lang)).tag(AppLanguage.system)
                Text("Íslenska").tag(AppLanguage.icelandic)
                Text("English").tag(AppLanguage.english)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }

    @ViewBuilder
    private var clearSection: some View {
        Section {
            Button(L.clearAllRecordings(settings.lang), role: .destructive) {
                confirmClear = true
            }
        }
    }

    @ViewBuilder
    private var footerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Text("KLUKK").font(.body.weight(.semibold))
                Text(L.copyright(settings.lang))
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
