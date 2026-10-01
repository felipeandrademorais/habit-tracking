import SwiftUI

struct MedalCardView: View {
    let medalStatus: MedalStatus

    private var isUnlocked: Bool { medalStatus.isUnlocked }
    private var medal: Medal { medalStatus.medal }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        isUnlocked
                        ? LinearGradient(
                            colors: [
                                LiquidGlassStyle.brandTint.opacity(0.28),
                                Color.color2.opacity(0.45)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.gray.opacity(0.08), Color.gray.opacity(0.12)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 58, height: 58)

                Image(systemName: medal.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(isUnlocked ? .defaultDark : .fontSoft.opacity(0.3))
            }

            Text(medal.name)
                .font(AppTheme.body(12))
                .foregroundColor(isUnlocked ? .fontSoft : .fontSoft.opacity(0.4))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .top)

            Text(medal.unlockCondition)
                .font(AppTheme.micro(9))
                .foregroundColor(isUnlocked ? .defaultDark.opacity(0.75) : .fontSoft.opacity(0.3))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity, minHeight: 24, alignment: .top)
        }
        .padding(12)
        .frame(width: 124)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.rowCornerRadius, style: .continuous)
                .fill(Color.calendarBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.rowCornerRadius, style: .continuous)
                .stroke(
                    isUnlocked ? LiquidGlassStyle.brandTint.opacity(0.28) : Color.clear,
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(isUnlocked ? 0.08 : 0.03), radius: 6, x: 0, y: 3)
        .opacity(isUnlocked ? 1 : 0.88)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(medal.name). \(medal.description). \(isUnlocked ? "Desbloqueada" : "Bloqueada")")
    }
}
