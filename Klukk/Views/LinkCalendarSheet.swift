import SwiftUI

/// Pre-permission explainer. Per App Review guideline 5.1.1(iv), the only action is
/// "Continue", which always proceeds to the system Calendar permission prompt — there
/// is no Skip / exit, and the sheet can't be swiped away.
struct LinkCalendarSheet: View {
    @Environment(AppSettings.self) private var settings
    /// Called after the permission prompt has been answered (granted or not).
    let onDone: () -> Void

    @State private var isRequesting = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Save your sessions to Calendar")
                    .font(.title2.weight(.bold))
                    .padding(.top, 8)

                Text("KLUKK saves every timed session as an event in your iOS Calendar. Continue to allow Calendar access. You can export any session as .ics, or the whole log as .xml, anytime afterwards.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Button {
                    Task { await requestAndFinish() }
                } label: {
                    Text("Continue")
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
        }
        .interactiveDismissDisabled()
    }

    private func requestAndFinish() async {
        isRequesting = true
        let granted = (try? await EventKitService.shared.requestAccess()) ?? false
        if granted, let def = EventKitService.shared.store.defaultCalendarForNewEvents {
            settings.selectedCalendarID = def.calendarIdentifier
            settings.selectedCalendarName = def.title
            settings.hasLinkedCalendar = true
        }
        settings.hasOnboarded = true
        settings.save()
        isRequesting = false
        onDone()
    }
}
