import SwiftUI
import UIKit

struct DurationPickerSheet: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    @State private var duration: TimeInterval
    let onSet: (TimeInterval?) -> Void

    init(initial: TimeInterval?, onSet: @escaping (TimeInterval?) -> Void) {
        _duration = State(initialValue: initial ?? 0)
        self.onSet = onSet
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DurationWheel(duration: $duration, lang: settings.lang)
                    .frame(maxHeight: 216)
                Text(L.targetSoundHint(settings.lang))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer(minLength: 0)
            }
            .padding(.top)
            .navigationTitle(L.targetTime(settings.lang))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L.clear(settings.lang)) { onSet(nil); dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L.set(settings.lang)) {
                        onSet(duration > 0 ? duration : nil)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.height(360)])
    }
}

/// Hours/minutes wheel. UIDatePicker.countDownTimer can't localize its unit
/// labels, so this is a plain two-component UIPickerView with explicit labels.
private struct DurationWheel: UIViewRepresentable {
    @Binding var duration: TimeInterval
    let lang: Lang

    private var hours: Int { Int(duration) / 3600 }
    private var minutes: Int { (Int(duration) % 3600) / 60 }

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIView(_ picker: UIPickerView, context: Context) {
        context.coordinator.lang = lang
        picker.reloadAllComponents()
        if picker.selectedRow(inComponent: 0) != hours {
            picker.selectRow(hours, inComponent: 0, animated: false)
        }
        if picker.selectedRow(inComponent: 1) != minutes {
            picker.selectRow(minutes, inComponent: 1, animated: false)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        let parent: DurationWheel
        var lang: Lang
        init(_ parent: DurationWheel) { self.parent = parent; self.lang = parent.lang }

        private var hourUnit: String { lang == .is_ ? "klst" : "hrs" }
        private var minuteUnit: String { lang == .is_ ? "mín" : "min" }

        func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            component == 0 ? 24 : 60
        }
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            component == 0 ? "\(row) \(hourUnit)" : "\(row) \(minuteUnit)"
        }
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let h = pickerView.selectedRow(inComponent: 0)
            let m = pickerView.selectedRow(inComponent: 1)
            parent.duration = TimeInterval(h * 3600 + m * 60)
        }
    }
}
