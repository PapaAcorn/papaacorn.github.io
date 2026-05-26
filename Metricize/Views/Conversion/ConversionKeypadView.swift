//
//  ConversionKeypadView.swift
//  Metricize
//

import SwiftUI

struct ConversionKeypadView: View {
    let allowsFractions: Bool
    var allowsMixedLength: Bool = false
    let onToken: (String) -> Void
    let onBackspace: () -> Void
    let onClear: () -> Void

    @Environment(\.metricPalette) private var palette

    private let rows: [[KeypadKey]] = [
        [.digit("1"), .digit("2"), .digit("3")],
        [.digit("4"), .digit("5"), .digit("6")],
        [.digit("7"), .digit("8"), .digit("9")],
        [.decimal, .digit("0"), .space],
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 10) {
                    ForEach(row) { key in
                        keypadButton(key)
                    }
                }
            }

            HStack(spacing: 10) {
                if allowsMixedLength {
                    keypadButton(.comma)
                }
                if allowsFractions {
                    keypadButton(.fraction)
                }
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
            case .comma:
                onToken(",")
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
                case .comma:
                    Text(",")
                        .font(.title2.weight(.medium).monospacedDigit())
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
            .frame(height: 48)
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
        .accessibilityLabel(key.accessibilityLabel)
    }
}

private enum KeypadKey: Identifiable {
    case digit(String)
    case decimal
    case space
    case fraction
    case comma
    case backspace
    case clear

    var id: String {
        switch self {
        case .digit(let value): "digit-\(value)"
        case .decimal: "decimal"
        case .space: "space"
        case .fraction: "fraction"
        case .comma: "comma"
        case .backspace: "backspace"
        case .clear: "clear"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .digit(let value): value
        case .decimal: "Decimal point"
        case .space: "Space"
        case .fraction: "Fraction slash"
        case .comma: "Comma"
        case .backspace: "Backspace"
        case .clear: "Clear"
        }
    }
}
