//
//  HereToTherePromptView.swift
//  Metricize
//

import SwiftUI

struct HereToTherePromptView: View {
    let card: HereToThereCard
    var compact: Bool = false

    @Environment(\.metricPalette) private var palette

    private var accent: Color {
        MetricTheme.coolFrost
    }

    var body: some View {
        promptText
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var promptText: some View {
        if let promptValue = card.promptValue, let promptUnit = card.promptUnit {
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
                .font(compact ? .title2.weight(.semibold) : .title.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
                .padding(.horizontal, 8)
        }
    }
}
