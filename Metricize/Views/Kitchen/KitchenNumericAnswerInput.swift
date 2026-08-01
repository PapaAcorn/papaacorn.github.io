//
//  KitchenNumericAnswerInput.swift
//  Metricize
//

import SwiftUI

struct KitchenNumericAnswerInput: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    var step: Double = 1
    let isEnabled: Bool
    var compact: Bool = false
    var accent: Color = MetricTheme.warmEmber

    @Environment(\.metricPalette) private var palette

    var body: some View {
        VStack(spacing: compact ? 10 : 14) {
            Text("\(Int(value.rounded()))")
                .font(.system(size: compact ? 36 : 48, weight: .thin, design: .rounded))
                .foregroundStyle(accent)
                .monospacedDigit()
                .contentTransition(.numericText())
                .frame(maxWidth: .infinity)

            Text(unit.trimmingCharacters(in: .whitespaces))
                .font(compact ? .subheadline : .title3)
                .foregroundStyle(palette.textSecondary)

            HStack(spacing: compact ? 10 : 14) {
                stepButton(label: "−1", delta: -step)

                Slider(
                    value: $value,
                    in: range,
                    step: step
                ) {
                    Text("Answer")
                }
                .tint(accent)
                .disabled(!isEnabled)

                stepButton(label: "+1", delta: step)
            }
            .padding(.horizontal, compact ? 4 : 8)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Answer entry")
        .accessibilityValue("\(Int(value.rounded())) \(unit)")
    }

    private func stepButton(label: String, delta: Double) -> some View {
        Button {
            adjust(by: delta)
        } label: {
            Text(label)
                .font(compact ? .subheadline.weight(.bold).monospacedDigit() : .headline.weight(.bold).monospacedDigit())
                .frame(width: compact ? 44 : 52, height: compact ? 44 : 52)
                .foregroundStyle(accent)
                .background {
                    Circle()
                        .fill(accent.opacity(isEnabled ? 0.14 : 0.06))
                        .overlay {
                            Circle()
                                .strokeBorder(accent.opacity(0.25), lineWidth: 1)
                        }
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    private func adjust(by delta: Double) {
        value = min(max(value + delta, range.lowerBound), range.upperBound)
    }
}
