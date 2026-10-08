import SwiftUI

extension View {
    /// Puts a list section closer to its neighbors, for a run of full-width buttons. Only iOS has the setting.
    func compactSectionSpacing() -> some View {
        #if os(iOS)
            listSectionSpacing(.compact)
        #else
            self
        #endif
    }
}
