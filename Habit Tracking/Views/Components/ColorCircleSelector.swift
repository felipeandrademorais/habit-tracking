//
//  ColorCircleSelector.swift
//  Habit Tracking
//
//  Created by Felipe Morais on 16/01/25.
//
import SwiftUI

struct ColorCircleSelector: View {
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 36, height: 36)
            .overlay(
                Circle()
                    .stroke(
                        isSelected ? LiquidGlassStyle.brandTint : Color.white.opacity(0.85),
                        lineWidth: isSelected ? 3 : 2
                    )
            )
            .overlay {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.fontSoft.opacity(0.7))
                }
            }
            .scaleEffect(isSelected ? 1.08 : 1)
            .animation(AppTheme.snappySpring, value: isSelected)
            .padding(.trailing, 4)
            .onTapGesture {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                onTap()
            }
    }
}
