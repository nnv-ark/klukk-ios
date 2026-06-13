import SwiftUI
import UIKit

struct DurationPickerSheet: View {
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
                DurationWheel(duration: $duration)
                    .frame(maxHeight: 216)
                Text("A sound plays when the running timer reaches this.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer(minLength: 0)
            }
            .padding(.top)
            .navigationTitle("Target time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear") { onSet(nil); dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Set") {
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

/// Native hours/minutes countdown wheel (UIDatePicker has no SwiftUI equivalent).
private struct DurationWheel: UIViewRepresentable {
    @Binding var duration: TimeInterval

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .countDownTimer
        picker.minuteInterval = 1
        picker.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
        return picker
    }

    func updateUIView(_ picker: UIDatePicker, context: Context) {
        if picker.countDownDuration != duration {
            picker.countDownDuration = duration
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject {
        let parent: DurationWheel
        init(_ parent: DurationWheel) { self.parent = parent }
        @MainActor @objc func changed(_ picker: UIDatePicker) {
            parent.duration = picker.countDownDuration
        }
    }
}
