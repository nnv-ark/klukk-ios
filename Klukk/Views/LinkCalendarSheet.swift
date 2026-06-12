import SwiftUI

struct LinkCalendarSheet: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    let onLinked: () -> Void

    @State private var isRequesting = false

    var body: some View {
        @Bindable var settings = settings
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("Where should KLUKK send your recordings?")
                    .font(.title2.weight(.bold))
                    .padding(.top, 8)

                ForEach(CalendarTarget.allCases) { target in
                    Button {
                        Task { await pick(target) }
                    } label: {
                        HStack {
                            Image(systemName: icon(for: target))
                                .font(.title3)
                                .frame(width: 36, height: 36)
                                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(target.label).font(.body.weight(.semibold))
                                Text(subtitle(for: target))
                                    .font(.caption).foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                        }
                        .padding()
                        .whiteCard()
                    }
                    .buttonStyle(.plain)
                    .disabled(isRequesting)
                }

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

    private func icon(for target: CalendarTarget) -> String {
        switch target {
        case .ios: "calendar"
        case .ics: "square.and.arrow.up"
        case .xml: "doc.text"
        }
    }

    private func subtitle(for target: CalendarTarget) -> String {
        switch target {
        case .ios: "Save to your iPhone's default calendar"
        case .ics: "Share each session as a .ics file"
        case .xml: "Append to a local XML document"
        }
    }

    private func pick(_ target: CalendarTarget) async {
        isRequesting = true
        defer { isRequesting = false }
        if target == .ios {
            let granted = (try? await EventKitService.shared.requestAccess()) ?? false
            guard granted else { return }
        }
        @Bindable var settings = settings
        settings.target = target
        onLinked()
    }
}
