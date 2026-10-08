import SwiftUI

/// A brand-colored badge for short tags such as "Yours" and "New".
struct TagBadge: View {
    let text: String

    var body: some View {
        StatusBadge(text: text, color: Theme.Colors.brand)
    }
}

#Preview {
    LightAndDarkPreview {
        TagBadge(text: "Yours")
        TagBadge(text: "New")
    }
}
