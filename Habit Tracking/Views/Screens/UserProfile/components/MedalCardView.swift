import SwiftUI

struct MedalCardView: View {
    let medalStatus: MedalStatus

    private var isUnlocked: Bool { medalStatus.isUnlocked }
    private var medal: Medal { medalStatus.medal }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.defaultDark.opacity(0.15) : Color.gray.opacity(0.08))
                    .frame(width: 56, height: 56)

                Image(systemName: medal.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(isUnlocked ? .defaultDark : .fontSoft.opacity(0.35))
            }

            Text(medal.name)
                .font(.custom("Poppins-Medium", size: 12))
                .foregroundColor(isUnlocked ? .fontSoft : .fontSoft.opacity(0.45))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .top)

            Text(medal.unlockCondition)
                .font(.custom("Poppins-Regular", size: 9))
                .foregroundColor(isUnlocked ? .defaultDark.opacity(0.8) : .fontSoft.opacity(0.35))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity, minHeight: 24, alignment: .top)
        }
        .padding(12)
        .frame(width: 120)
        .background(Color.calendarBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isUnlocked ? Color.defaultDark.opacity(0.25) : Color.clear, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(isUnlocked ? 0.08 : 0.03), radius: 2, x: 0, y: 2)
        .opacity(isUnlocked ? 1 : 0.85)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(medal.name). \(medal.description). \(isUnlocked ? "Desbloqueada" : "Bloqueada")")
    }
}
