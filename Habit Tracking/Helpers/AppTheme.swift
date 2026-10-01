import SwiftUI

/// Shared visual tokens for MetaFlow / Habit Tracking.
/// Complements Liquid Glass chrome with pastel surfaces, type, and motion.
enum AppTheme {
    // MARK: - Radii
    static let rowCornerRadius: CGFloat = 18
    static let surfaceCornerRadius: CGFloat = 22
    static let chipCornerRadius: CGFloat = 14
    static let iconWellSize: CGFloat = 44

    // MARK: - Spacing
    static let screenPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 24
    static let rowSpacing: CGFloat = 12

    // MARK: - Typography
    static func title(_ size: CGFloat = 22) -> Font {
        .custom("Poppins-SemiBold", size: size)
    }

    static func headline(_ size: CGFloat = 16) -> Font {
        .custom("Poppins-SemiBold", size: size)
    }

    static func body(_ size: CGFloat = 14) -> Font {
        .custom("Poppins-Medium", size: size)
    }

    static func caption(_ size: CGFloat = 12) -> Font {
        .custom("Poppins-Regular", size: size)
    }

    static func micro(_ size: CGFloat = 10) -> Font {
        .custom("Poppins-Regular", size: size)
    }

    // MARK: - Motion
    static let softSpring = Animation.spring(response: 0.35, dampingFraction: 0.82)
    static let snappySpring = Animation.spring(response: 0.28, dampingFraction: 0.78)

    // MARK: - Surfaces
    static var pageGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.color1.opacity(0.55),
                Color.blueSoft.opacity(0.85),
                Color.color2.opacity(0.35)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var habitsHeaderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.color1.opacity(0.75),
                Color.color1.opacity(0.35),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var softShadow: Color { Color.black.opacity(0.06) }
}

// MARK: - View helpers

extension View {
    /// Soft elevated pastel surface used for content blocks (not chrome).
    func habitSoftSurface(
        cornerRadius: CGFloat = AppTheme.surfaceCornerRadius,
        fill: Color = .calendarBackground
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
                    .shadow(color: AppTheme.softShadow, radius: 10, x: 0, y: 4)
            )
    }

    func habitPageBackground() -> some View {
        self.background {
            AppTheme.pageGradient
                .ignoresSafeArea()
        }
    }

    func appearSoftly(delay: Double = 0) -> some View {
        modifier(AppearSoftlyModifier(delay: delay))
    }
}

private struct AppearSoftlyModifier: ViewModifier {
    let delay: Double
    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 10)
            .onAppear {
                withAnimation(AppTheme.softSpring.delay(delay)) {
                    visible = true
                }
            }
    }
}
