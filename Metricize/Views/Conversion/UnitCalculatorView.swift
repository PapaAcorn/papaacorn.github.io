//
//  UnitCalculatorView.swift
//  Metricize
//

import SwiftUI

struct UnitCalculatorView: View {
    @Environment(\.metricPalette) private var palette

    @Bindable var viewModel: UnitCalculatorViewModel
    @State private var showSendWarning = false

    let onSendToConverter: (String, ConversionCategory, ConversionUnit) -> Void

    init(
        viewModel: UnitCalculatorViewModel,
        onSendToConverter: @escaping (String, ConversionCategory, ConversionUnit) -> Void
    ) {
        self.viewModel = viewModel
        self.onSendToConverter = onSendToConverter
    }

    init(
        category: ConversionCategory,
        unit: ConversionUnit,
        onSendToConverter: @escaping (String, ConversionCategory, ConversionUnit) -> Void
    ) {
        self.init(
            viewModel: UnitCalculatorViewModel(category: category, unit: unit),
            onSendToConverter: onSendToConverter
        )
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 20) {
            unitContextPickers
            displayPanel
            calculatorKeypad
            sendButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .metricScreenBackground()
        .sheet(isPresented: $showSendWarning) {
            SendToConverterWarningSheet(isPresented: $showSendWarning) {
                completeSendToConverter()
            }
        }
    }

    private var unitContextPickers: some View {
        HStack(spacing: 10) {
            ConversionCategoryMenu(selection: $viewModel.category)
                .frame(maxWidth: .infinity)

            ConversionUnitMenu(
                title: "Unit",
                units: viewModel.availableUnits,
                selection: $viewModel.unit,
                category: viewModel.category
            )
            .frame(maxWidth: .infinity)
        }
    }

    private var displayPanel: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(viewModel.unit.symbol)
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.textTertiary)

            Text(viewModel.display)
                .font(.system(size: 48, weight: .light, design: .rounded))
                .foregroundStyle(palette.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.4)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibilityLabel("Calculator result")
                .accessibilityValue("\(viewModel.display) \(viewModel.unit.symbol)")
        }
        .padding(20)
        .background(pickerBackground)
    }

    private var calculatorKeypad: some View {
        VStack(spacing: 10) {
            keypadRow([
                (.function("C"), { viewModel.clear() }),
                (.function("±"), { viewModel.toggleSign() }),
                (.function("%"), { viewModel.applyPercent() }),
                (.operation(.divide), { viewModel.applyOperation(.divide) }),
            ])
            keypadRow([
                (.digit("7"), { viewModel.appendDigit("7") }),
                (.digit("8"), { viewModel.appendDigit("8") }),
                (.digit("9"), { viewModel.appendDigit("9") }),
                (.operation(.multiply), { viewModel.applyOperation(.multiply) }),
            ])
            keypadRow([
                (.digit("4"), { viewModel.appendDigit("4") }),
                (.digit("5"), { viewModel.appendDigit("5") }),
                (.digit("6"), { viewModel.appendDigit("6") }),
                (.operation(.subtract), { viewModel.applyOperation(.subtract) }),
            ])
            keypadRow([
                (.digit("1"), { viewModel.appendDigit("1") }),
                (.digit("2"), { viewModel.appendDigit("2") }),
                (.digit("3"), { viewModel.appendDigit("3") }),
                (.operation(.add), { viewModel.applyOperation(.add) }),
            ])

            keypadRow([
                (.function(viewModel.fractionToggleLabel), { viewModel.toggleFractionDecimal() }),
                (.function("␣"), { viewModel.appendSpace() }),
                (.function("/"), { viewModel.appendSlash() }),
            ])

            keypadRow([
                (.function("⌫"), { viewModel.backspace() }),
                (.digit("0"), { viewModel.appendDigit("0") }),
                (.function("."), { viewModel.appendDecimal() }),
                (.equals, { viewModel.equals() }),
            ])
        }
    }

    private var sendButton: some View {
        PrimaryActionButton(title: "Send to Converter", isEnabled: viewModel.hasPendingResult) {
            requestSendToConverter()
        }
    }

    private func requestSendToConverter() {
        if CalculatorSendPreferences.suppressSendWarning {
            completeSendToConverter()
        } else {
            showSendWarning = true
        }
    }

    private func completeSendToConverter() {
        onSendToConverter(viewModel.converterValue, viewModel.category, viewModel.unit)
    }

    private var pickerBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(palette.cardFill)
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(palette.glassStroke, lineWidth: 1)
            }
    }

    private enum CalcKey {
        case digit(String)
        case function(String)
        case operation(UnitCalculatorViewModel.Operation)
        case equals
    }

    private func keypadRow(_ keys: [(CalcKey, () -> Void)]) -> some View {
        HStack(spacing: 10) {
            ForEach(Array(keys.enumerated()), id: \.offset) { _, entry in
                calculatorButton(entry.0, action: entry.1)
            }
        }
    }

    private func calculatorButton(_ key: CalcKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Group {
                switch key {
                case .digit(let value):
                    Text(value)
                case .function(let label):
                    Text(label)
                case .operation(let operation):
                    Text(operation.symbol)
                case .equals:
                    Text("=")
                }
            }
            .font(.title3.weight(.semibold).monospacedDigit())
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(keyForeground(key))
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(keyBackground(key))
            }
        }
        .buttonStyle(.plain)
    }

    private func keyForeground(_ key: CalcKey) -> Color {
        switch key {
        case .operation, .equals:
            return .white
        default:
            return palette.textPrimary
        }
    }

    private func keyBackground(_ key: CalcKey) -> AnyShapeStyle {
        switch key {
        case .operation, .equals:
            return AnyShapeStyle(MetricTheme.primaryButton)
        case .function:
            return AnyShapeStyle(palette.cardFillMuted)
        case .digit:
            return AnyShapeStyle(palette.chipFill)
        }
    }
}

#Preview {
    UnitCalculatorView(category: .distance, unit: .inches) { _, _, _ in }
        .environment(\.metricPalette, MetricPalette.dark)
}
