import SwiftUI

struct StatCardView: View {
    let title: String
    let value: Int
    var systemImage: String = "chart.bar.fill"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(LiquidGlassStyle.brandTint)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(LiquidGlassStyle.brandTint.opacity(0.12))
                )

            Text("\(value)")
                .font(AppTheme.title(24))
                .foregroundColor(.fontSoft)
                .contentTransition(.numericText())

            Text(title)
                .font(AppTheme.caption(12))
                .foregroundColor(.fontSoft.opacity(0.55))
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .habitSoftSurface(cornerRadius: AppTheme.rowCornerRadius)
    }
}
