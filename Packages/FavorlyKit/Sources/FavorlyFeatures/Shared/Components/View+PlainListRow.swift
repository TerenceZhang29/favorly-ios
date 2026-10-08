import SwiftUI

extension View {
    /// A list row with no card behind it and no insets, for full-width buttons and centered messages.
    func plainListRow() -> some View {
        listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}
