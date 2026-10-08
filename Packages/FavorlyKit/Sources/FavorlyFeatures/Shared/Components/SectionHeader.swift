import SwiftUI

/// A list section header in sentence case, a little larger and darker than the system default.
struct SectionHeader: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.primary)
            .textCase(nil)
    }
}

#Preview {
    LightAndDarkPreview {
        SectionHeader(text: "What do you need?")
        SectionHeader(text: "7 requests")
    }
}
