import SwiftUI

/// Compact day summary shown above today's habit list.
struct DayProgressHeaderView: View {
    let completedCount: Int
    let totalCount: Int
    let date: Date

    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    private var titleText: String {
        if Calendar.current.isDateInToday(date) {
            return "Hoje"
        }
        if Calendar.current.isDateInYesterday(date) {
            return "Ontem"
        }
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date).capitalized
    }

    private var subtitleText: String {
        guard totalCount > 0 else {
            return "Nenhum hábito neste dia"
        }
        if completedCount == totalCount {
            return "Dia perfeito — todos concluídos"
        }
        return "\(completedCount) de \(totalCount) concluídos"
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.55), lineWidth: 6)
                    .frame(width: 52, height: 52)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LiquidGlassStyle.brandTint,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
                    .animation(AppTheme.softSpring, value: progress)

                Text("\(Int((progress * 100).rounded()))%")
                    .font(AppTheme.micro(11))
                    .foregroundColor(.fontSoft)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(titleText)
                    .font(AppTheme.title(20))
                    .foregroundColor(.fontSoft)

                Text(subtitleText)
                    .font(AppTheme.caption(13))
                    .foregroundColor(.fontSoft.opacity(0.65))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .habitSoftSurface(fill: Color.calendarBackground.opacity(0.92))
        .appearSoftly()
    }
}
