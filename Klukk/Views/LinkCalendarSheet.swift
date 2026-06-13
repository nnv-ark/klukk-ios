import SwiftUI

struct LinkCalendarSheet: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    let onLinked: () -> Void

    @State private var isRequesting = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Save your sessions to Calendar")
                    .font(.title2.weight(.bold))
                    .padding(.top, 8)

                Text("KLUKK turns every timed session into an event in your iOS Calendar. You can export any session as a .ics file, or the whole log as .xml, anytime afterwards.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Button {
                    Task { await link() }
                } label: {
                    Text("Link calendar")
                        .font(.body.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .background(Color.yellow, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.black)
                .disabled(isRequesting)

                Spacer()
                Text("© NNV ehf. · All rights reserved")
                    .font(.caption2).foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Link a calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip") { dismiss() }
                }
            }
        }
    }

    private func link() async {
        isRequesting = true
        defer { isRequesting = false }
        let granted = (try? await EventKitService.shared.requestAccess()) ?? false
        guard granted else { return }
        if let def = EventKitService.shared.store.defaultCalendarForNewEvents {
            settings.selectedCalendarID = def.calendarIdentifier
            settings.selectedCalendarName = def.title
        }
        onLinked()
    }
}
