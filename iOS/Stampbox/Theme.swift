import SwiftUI

/// Stampbox's unique visual identity - a palette and mood distinct from every
/// sibling app in this portfolio, tuned to the stamp domain.
enum AppTheme {
    static let background = Color(red: 0.055, green: 0.071, blue: 0.086)
    static let card = Color(red: 0.082, green: 0.102, blue: 0.125)
    static let accent = Color(red: 0.227, green: 0.431, blue: 0.647)
    static let secondary = Color(red: 0.690, green: 0.278, blue: 0.243)
    static let primaryText = Color(red: 0.914, green: 0.933, blue: 0.953)
    static let mutedText = Color(red: 0.914, green: 0.933, blue: 0.953).opacity(0.6)

    static let titleFont: Font = .system(.title2, design: .serif).weight(.bold)
    static let headlineFont: Font = .system(.headline, design: .rounded)
    static let bodyFont: Font = .system(.body, design: .rounded)
    static let captionFont: Font = .system(.caption, design: .monospaced)

    static let cornerRadius: CGFloat = 16
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppTheme.card)
            .cornerRadius(AppTheme.cornerRadius)
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardBackground()) }
}
