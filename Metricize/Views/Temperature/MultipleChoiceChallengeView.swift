//
//  MultipleChoiceChallengeView.swift
//  Metricize
//

import SwiftUI

struct MultipleChoiceChallengeView: View {
    let card: TemperatureCard
    let choices: [Int]
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
                    prompt
                    choiceList
                }
            case .sideBySide:
                HStack(alignment: .center, spacing: compact ? 16 : 28) {
                    prompt
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

    private var prompt: some View {
        TemperaturePromptView(
            value: card.promptValue,
            unit: card.promptUnit,
            compact: compact
        )
    }

    private var choiceList: some View {
        VStack(spacing: compact ? 6 : 10) {
            ForEach(Array(choices.enumerated()), id: \.element) { index, choice in
                ChoiceButton(
                    value: choice,
                    unit: card.answerUnit,
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
}

private struct ChoiceButton: View {
    let value: Int
    let unit: String
    let isEnabled: Bool
    let delay: Double
    let appeared: Bool
    var compact: Bool = false
    let action: () -> Void

    @State private var isPressed = false
    @Environment(\.metricPalette) private var palette

    private var accent: Color {
        if unit == "°F" {
            MetricTheme.fahrenheitHue(Double(value))
        } else {
            MetricTheme.palette(forCelsius: value).glow
        }
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

                Text("\(value)\(unit)")
                    .font(compact ? .body.weight(.semibold).monospacedDigit() : .title3.weight(.semibold).monospacedDigit())
                    .foregroundStyle(palette.textPrimary)

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
