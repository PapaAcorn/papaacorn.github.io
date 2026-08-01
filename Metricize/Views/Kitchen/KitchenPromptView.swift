//
//  KitchenPromptView.swift
//  Metricize
//

import SwiftUI

struct KitchenPromptView: View {
    let card: KitchenCard
    var compact: Bool = false

    @Environment(\.metricPalette) private var palette

    private var accent: Color {
        if card.usesTemperatureSlider {
            let celsius = card.direction == .imperialToMetric
                ? card.correctAnswer
                : (card.promptValue ?? card.correctAnswer)
            return MetricTheme.palette(forCelsius: celsius).glow
        }
        return MetricTheme.warmEmber
    }

    var body: some View {
        promptText
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var promptText: some View {
        if card.kind == .booleanComparison {
            Text(card.prompt)
                .font(compact ? .title2.weight(.semibold) : .title.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
                .padding(.horizontal, 8)
        } else if let promptValue = card.promptValue, let promptUnit = card.promptUnit {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(promptValue)")
                    .font(.system(size: compact ? 48 : 72, weight: .thin, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [accent, accent.opacity(0.75)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .contentTransition(.numericText())

                Text(promptUnit)
                    .font(.system(size: compact ? 20 : 28, weight: .light, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
                    .offset(y: compact ? -4 : -8)
            }
        } else {
            Text(card.prompt)
                .font(.system(size: compact ? 34 : 48, weight: .semibold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [accent, accent.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
    }
}
