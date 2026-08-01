//
//  ConversionKeypadView.swift
//  Metricize
//

import SwiftUI

struct ConversionKeypadView: View {
    let fractionToggleLabel: String
    var compact: Bool = false
    let onToken: (String) -> Void
    let onBackspace: () -> Void
    let onClear: () -> Void
    let onToggleFractionDecimal: () -> Void

    @Environment(\.metricPalette) private var palette

    private var buttonHeight: CGFloat { compact ? 40 : 48 }
    private var rowSpacing: CGFloat { compact ? 8 : 10 }

    private let rows: [[KeypadKey]] = [
        [.digit("1"), .digit("2"), .digit("3")],
        [.digit("4"), .digit("5"), .digit("6")],
        [.digit("7"), .digit("8"), .digit("9")],
        [.decimal, .digit("0"), .space],
    ]

    var body: some View {
        VStack(spacing: rowSpacing) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: rowSpacing) {
                    ForEach(row) { key in
                        keypadButton(key)
                    }
                }
            }

            HStack(spacing: rowSpacing) {
                keypadButton(.fraction)
                keypadButton(.fractionToggle)
                keypadButton(.backspace)
                keypadButton(.clear)
            }
        }
    }

    @ViewBuilder
    private func keypadButton(_ key: KeypadKey) -> some View {
        Button {
            switch key {
            case .digit(let value):
                onToken(value)
            case .decimal:
                onToken(".")
            case .space:
                onToken(" ")
            case .fraction:
                onToken("/")
            case .fractionToggle:
                onToggleFractionDecimal()
            case .backspace:
                onBackspace()
            case .clear:
                onClear()
            }
        } label: {
            Group {
                switch key {
                case .backspace:
                    Image(systemName: "delete.left")
                        .font(.body.weight(.semibold))
                case .clear:
                    Text("Clear")
                        .font(.subheadline.weight(.semibold))
                case .fraction:
                    Text("/")
                        .font(.title2.weight(.medium).monospacedDigit())
                case .fractionToggle:
                    Text(fractionToggleLabel)
                        .font(.subheadline.weight(.semibold))
                case .space:
                    Text("␣")
                        .font(.caption.weight(.bold))
                case .decimal:
                    Text(".")
                        .font(.title2.weight(.medium).monospacedDigit())
                case .digit(let value):
                    Text(value)
                        .font(.title2.weight(.medium).monospacedDigit())
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .foregroundStyle(palette.textPrimary)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(palette.chipFill)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(palette.chipStroke, lineWidth: 1)
                    }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(key.accessibilityLabel(fractionToggleLabel: fractionToggleLabel))
    }
}

private enum KeypadKey: Identifiable {
    case digit(String)
    case decimal
    case space
    case fraction
    case fractionToggle
    case backspace
    case clear

    var id: String {
        switch self {
        case .digit(let value): "digit-\(value)"
        case .decimal: "decimal"
        case .space: "space"
        case .fraction: "fraction"
        case .fractionToggle: "fraction-toggle"
        case .backspace: "backspace"
        case .clear: "clear"
        }
    }

    func accessibilityLabel(fractionToggleLabel: String) -> String {
        switch self {
        case .digit(let value): value
        case .decimal: "Decimal point"
        case .space: "Space"
        case .fraction: "Fraction slash"
        case .fractionToggle: "Toggle fraction or decimal (\(fractionToggleLabel))"
        case .backspace: "Backspace"
        case .clear: "Clear"
        }
    }
}
