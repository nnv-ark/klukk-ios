import SwiftUI

struct PresetsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var showAdd = false
    @State private var newPreset = ""

    var body: some View {
        @Bindable var settings = settings
        Form {
            Section("Your presets") {
                ForEach(settings.titlePresets, id: \.self) { preset in
                    Button {
                        settings.titleTemplate = preset
                        settings.save()
                        dismiss()
                    } label: {
                        HStack {
                            Text(preset)
                                .font(.body.monospaced())
                                .foregroundStyle(.primary)
                            Spacer()
                            if preset == settings.titleTemplate {
                                Image(systemName: "checkmark").foregroundStyle(.tint)
                            }
                        }
                    }
                }
                .onDelete { offsets in
                    settings.titlePresets.remove(atOffsets: offsets)
                    settings.save()
                }
            }

            Section {
                Button {
                    newPreset = ""
                    showAdd = true
                } label: {
                    Label("Add preset", systemImage: "plus")
                }
            } footer: {
                Text("Tokens: \(AppSettings.templateTokens)")
            }
        }
        .navigationTitle("Presets")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Add preset", isPresented: $showAdd) {
            TextField("e.g. Session {time}", text: $newPreset)
            Button("Cancel", role: .cancel) {}
            Button("Add") {
                settings.addPreset(newPreset)
                settings.titleTemplate = newPreset.trimmingCharacters(in: .whitespaces)
                settings.save()
            }
        } message: {
            Text("Use tokens: \(AppSettings.templateTokens)")
        }
    }
}
