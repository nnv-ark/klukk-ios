import SwiftUI

extension View {
    /// A fixed-white rounded card whose contents always render in light appearance,
    /// so dark text/secondary styles stay readable even when the phone is in dark mode.
    func whiteCard(cornerRadius: CGFloat = 14) -> some View {
        background(.white, in: RoundedRectangle(cornerRadius: cornerRadius))
            .environment(\.colorScheme, .light)
    }
}
