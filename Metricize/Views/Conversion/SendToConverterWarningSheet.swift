//
//  SendToConverterWarningSheet.swift
//  Metricize
//

import SwiftUI

struct SendToConverterWarningSheet: View {
    @Environment(\.metricPalette) private var palette

    @Binding var isPresented: Bool
    @State private var doNotShowAgain = false

    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Before you convert")
                .font(.title3.weight(.semibold))
                .foregroundStyle(palette.textPrimary)

            Text(
                "Performing calculations in one unit and converting to another can introduce errors which compound over time. It's best to perform calculations in the units you'll actually use when possible."
            )
            .font(.body)
            .foregroundStyle(palette.textSecondary)
            .fixedSize(horizontal: false, vertical: true)

            Toggle(isOn: $doNotShowAgain) {
                Text("Don't show this warning again")
                    .font(.subheadline)
                    .foregroundStyle(palette.textPrimary)
            }
            .tint(MetricTheme.warmEmber)

            PrimaryActionButton(title: "Continue") {
                if doNotShowAgain {
                    CalculatorSendPreferences.suppressSendWarning = true
                }
                isPresented = false
                onConfirm()
            }

            Button("Cancel") {
                isPresented = false
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(palette.textSecondary)
            .frame(maxWidth: .infinity)
        }
        .padding(24)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
