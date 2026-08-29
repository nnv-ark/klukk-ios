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
                Text(L.saveSessionsToCalendar(settings.lang))
                    .font(.title2.weight(.bold))
                    .padding(.top, 8)

                Text(L.linkCalendarBody(settings.lang))
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Button {
                    Task { await requestAndFinish() }
                } label: {
                    Text(L.continueButton(settings.lang))
                        .font(.body.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .background(Color.yellow, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.black)
                .disabled(isRequesting)

                Spacer()
                Text(L.copyright(settings.lang))
                    .font(.caption2).foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle(L.linkACalendar(settings.lang))
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
