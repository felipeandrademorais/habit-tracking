import SwiftUI

/// Shared Liquid Glass tokens and modifiers for Habit Tracker chrome.
/// Content surfaces (habit rows, pastel page fills) stay opaque; glass is for controls/navigation.
enum LiquidGlassStyle {
    static let chromeCornerRadius: CGFloat = 22
    static let cardCornerRadius: CGFloat = 14
    static let alertCornerRadius: CGFloat = 18
    static let fabSize: CGFloat = 58

    static var brandTint: Color { .defaultDark }
    static var primaryCapsuleTint: Color { .capsulePrimary }
}

extension View {
    /// Regular glass chrome for floating panels and alerts.
    func habitGlassPanel(cornerRadius: CGFloat = LiquidGlassStyle.chromeCornerRadius) -> some View {
        glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
    }

    /// Interactive tinted glass for selected chips / day capsules.
    func habitGlassChip(tint: Color = LiquidGlassStyle.primaryCapsuleTint) -> some View {
        glassEffect(
            .regular.tint(tint).interactive(),
            in: .rect(cornerRadius: LiquidGlassStyle.cardCornerRadius)
        )
    }

    /// Circular interactive glass (day selectors, small controls).
    func habitGlassCircle(tint: Color? = nil) -> some View {
        let glass: Glass = {
            if let tint {
                return .regular.tint(tint).interactive()
            }
            return .regular.interactive()
        }()
        return glassEffect(glass, in: .circle)
    }
}
