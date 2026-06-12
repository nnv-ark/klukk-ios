import SwiftUI

struct RenameSheet: View {
    let session: Session
    let onSave: (String) -> Void
    let onDiscard: () -> Void

    @State private var title: String

    init(session: Session, onSave: @escaping (String) -> Void, onDiscard: @escaping () -> Void) {
        self.session = session
        self.onSave = onSave
        self.onDiscard = onDiscard
        _title = State(initialValue: session.title)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("\(Format.timeOfDay.string(from: session.startedAt)) · \(Format.durationLong(session.duration))")
                    .font(.caption).foregroundStyle(.secondary)
                TextField("Title", text: $title)
                    .textFieldStyle(.plain)
                    .font(.title3.weight(.semibold))
                    .padding(14)
                    .background(.white, in: RoundedRectangle(cornerRadius: 14))
                    .environment(\.colorScheme, .light)

                HStack(spacing: 10) {
                    Button(role: .cancel) {
                        onDiscard()
                    } label: {
                        Text("Discard")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundStyle(.black)
                    }
                    .background(.white, in: RoundedRectangle(cornerRadius: 14))

                    Button {
                        let trimmed = title.trimmingCharacters(in: .whitespaces)
                        onSave(trimmed.isEmpty ? session.title : trimmed)
                    } label: {
                        Text("Save to calendar")
                            .font(.body.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .background(Color.yellow, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.black)
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Name event")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
