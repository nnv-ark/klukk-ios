import SwiftUI

struct SettingsSheet: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    let onClear: () -> Void

    @State private var confirmClear = false

    var body: some View {
        @Bindable var settings = settings
        NavigationStack {
            Form {
                Section("Send recordings to") {
                    Picker("Destination", selection: $settings.target) {
                        ForEach(CalendarTarget.allCases) { target in
                            Text(target.label).tag(target)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                if settings.target == .ios {
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

                Section("Naming") {
                    TextField("Title template", text: $settings.titleTemplate)
                        .font(.body.monospaced())
                    Text("Tokens: {time} {date} {n} {duration}")
                        .font(.caption).foregroundStyle(.secondary)
                    Toggle("Ask to rename after stop", isOn: $settings.confirmRename)
                }

                Section("Behavior") {
                    Toggle("Show centiseconds", isOn: $settings.showCentiseconds)
                    Toggle("Haptic on start/stop", isOn: $settings.haptic)
                }

                Section {
                    Button("Clear all recordings", role: .destructive) {
                        confirmClear = true
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("KLUKK").font(.body.weight(.semibold))
                        Text("© NNV ehf. · All rights reserved")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
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
        }
    }
}
