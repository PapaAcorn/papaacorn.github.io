//
//  KitchenMeasurementSliderView.swift
//  Metricize
//

import SwiftUI

struct KitchenMeasurementSliderView: View {
    let card: KitchenCard
    @Binding var selectedValue: Double
    let isEnabled: Bool
    var layout: ChallengeLayout = .stacked
    var compact: Bool = false

    @Environment(\.metricPalette) private var palette

    private var range: ClosedRange<Double> {
        Double(card.answerRange.lowerBound)...Double(card.answerRange.upperBound)
    }

    private var accent: Color {
        MetricTheme.warmEmber
    }

    var body: some View {
        Group {
            switch layout {
            case .stacked:
                VStack(spacing: 28) {
                    if card.kind != .foodSafetyTemperature {
                        KitchenPromptView(card: card, compact: compact)
                    }
                    KitchenNumericAnswerInput(
                        value: $selectedValue,
                        range: range,
                        unit: card.answerUnit,
                        step: 1,
                        isEnabled: isEnabled,
                        compact: compact,
                        accent: accent
                    )
                }
            case .sideBySide:
                KitchenNumericAnswerInput(
                    value: $selectedValue,
                    range: range,
                    unit: card.answerUnit,
                    step: 1,
                    isEnabled: isEnabled,
                    compact: compact,
                    accent: accent
                )
            }
        }
        .padding(.horizontal, 8)
        .onAppear {
            selectedValue = defaultValue
        }
        .onChange(of: card.id) { _, _ in
            selectedValue = defaultValue
        }
    }

    private var defaultValue: Double {
        KitchenConversion.neutralSliderDefault(for: card)
    }
}
