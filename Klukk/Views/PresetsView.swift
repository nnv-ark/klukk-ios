import SwiftUI

struct PresetsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var showAdd = false
    @State private var newPreset = ""

    var body: some View {
        @Bindable var settings = settings
        Form {
            Section(L.yourPresets(settings.lang)) {
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
                    Label(L.addPreset(settings.lang), systemImage: "plus")
                }
            } footer: {
                Text(L.tokens(settings.lang, AppSettings.templateTokens))
            }
        }
        .navigationTitle(L.presets(settings.lang))
        .navigationBarTitleDisplayMode(.inline)
        .alert(L.addPreset(settings.lang), isPresented: $showAdd) {
            TextField(L.presetPlaceholder(settings.lang), text: $newPreset)
            Button(L.cancel(settings.lang), role: .cancel) {}
            Button(L.add(settings.lang)) {
                settings.addPreset(newPreset)
                settings.titleTemplate = newPreset.trimmingCharacters(in: .whitespaces)
                settings.save()
            }
        } message: {
            Text(L.useTokens(settings.lang, AppSettings.templateTokens))
        }
    }
}
