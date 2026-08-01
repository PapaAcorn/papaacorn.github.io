//
//  KitchenMultipleChoiceChallengeView.swift
//  Metricize
//

import SwiftUI

struct KitchenMultipleChoiceChallengeView: View {
    let card: KitchenCard
    let choices: [Int]
    var choiceLabels: [String]? = nil
    let isEnabled: Bool
    let onSelect: (Int) -> Void
    var layout: ChallengeLayout = .stacked
    var compact: Bool = false

    @State private var appeared = false
    @Environment(\.metricPalette) private var palette

    var body: some View {
        Group {
            switch layout {
            case .stacked:
                VStack(spacing: compact ? 20 : 32) {
                    KitchenPromptView(card: card, compact: compact)
                    choiceList
                }
            case .sideBySide:
                HStack(alignment: .center, spacing: compact ? 16 : 28) {
                    KitchenPromptView(card: card, compact: compact)
                        .frame(maxWidth: .infinity)
                    choiceList
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 4)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                appeared = true
            }
        }
        .onChange(of: choices) { _, _ in
            appeared = false
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82).delay(0.05)) {
                appeared = true
            }
        }
    }

    private var choiceList: some View {
        VStack(spacing: compact ? 6 : 10) {
            ForEach(Array(choices.enumerated()), id: \.element) { index, choice in
                KitchenChoiceButton(
                    card: card,
                    value: choice,
                    displayLabel: label(for: choice, at: index),
                    isEnabled: isEnabled,
                    delay: Double(index) * 0.06,
                    appeared: appeared,
                    compact: compact
                ) {
                    onSelect(choice)
                }
            }
        }
    }

    private func label(for choice: Int, at index: Int) -> String? {
        guard let choiceLabels, choiceLabels.indices.contains(choice) else { return nil }
        return choiceLabels[choice]
    }
}

private struct KitchenChoiceButton: View {
    let card: KitchenCard
    let value: Int
    var displayLabel: String? = nil
    let isEnabled: Bool
    let delay: Double
    let appeared: Bool
    var compact: Bool = false
    let action: () -> Void

    @State private var isPressed = false
    @Environment(\.metricPalette) private var palette

    private var accent: Color {
        if card.kind == .booleanComparison {
            return value == 1 ? MetricTheme.success : MetricTheme.warmEmber
        }
        if card.usesTemperatureSlider {
            if card.answerUnit == "°F" {
                return MetricTheme.fahrenheitHue(Double(value))
            }
            return MetricTheme.palette(forCelsius: value).glow
        }
        return MetricTheme.warmEmber
    }

    private var label: String {
        if let displayLabel {
            return displayLabel
        }
        if card.kind == .booleanComparison {
            return KitchenFormatting.booleanPhrase(isYes: value == 1)
        }
        if card.answerUnit == "°F" || card.answerUnit == "°C" {
            return "\(value)\(card.answerUnit)"
        }
        return KitchenFormatting.answerPhrase(value: value, unit: card.answerUnit)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Circle()
                    .fill(accent.opacity(0.25))
                    .frame(width: 10, height: 10)
                    .overlay {
                        Circle()
                            .fill(accent)
                            .frame(width: 6, height: 6)
                    }

                Text(label)
                    .font(compact ? .body.weight(.semibold) : .title3.weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.textTertiary)
            }
            .padding(.horizontal, compact ? 14 : 20)
            .padding(.vertical, compact ? 12 : 18)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(accent.opacity(isPressed ? 0.18 : 0.08))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                accent.opacity(isPressed ? 0.5 : 0.2),
                                lineWidth: 1
                            )
                    }
            }
            .scaleEffect(isPressed ? 0.98 : 1)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.45, dampingFraction: 0.8).delay(delay), value: appeared)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct KitchenBooleanChoiceView: View {
    let card: KitchenCard
    let isEnabled: Bool
    let onSelect: (Bool) -> Void
    var compact: Bool = false

    var body: some View {
        VStack(spacing: compact ? 20 : 32) {
            KitchenPromptView(card: card, compact: compact)

            HStack(spacing: 16) {
                booleanButton(title: "Yes", isYes: true, tint: MetricTheme.success)
                booleanButton(title: "No", isYes: false, tint: MetricTheme.warmEmber)
            }
            .padding(.horizontal, 8)
        }
    }

    private func booleanButton(title: String, isYes: Bool, tint: Color) -> some View {
        Button {
            onSelect(isYes)
        } label: {
            Text(title)
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .foregroundStyle(.white)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(tint.opacity(isEnabled ? 0.85 : 0.35))
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
