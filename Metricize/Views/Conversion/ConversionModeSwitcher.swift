//
//  ConversionModeSwitcher.swift
//  Metricize
//

import SwiftUI

struct ConversionModeSwitcher: View {
    @Environment(\.metricPalette) private var palette

    @Binding var selection: ConversionScreen
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            modeButton(title: "Converter", screen: .converter)
            modeButton(title: "Calculator", screen: .calculator)
        }
        .padding(compact ? 3 : 4)
        .background {
            Capsule(style: .continuous)
                .fill(palette.chipFill)
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(palette.chipStroke, lineWidth: 1)
                }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Conversion mode")
        .accessibilityValue(selection == .converter ? "Converter" : "Calculator")
    }

    private func modeButton(title: String, screen: ConversionScreen) -> some View {
        let isSelected = selection == screen

        return Button {
            selection = screen
        } label: {
            Text(title)
                .font(compact ? .caption.weight(.semibold) : .subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? palette.textPrimary : palette.textSecondary.opacity(0.72))
                .padding(.horizontal, compact ? 10 : 14)
                .padding(.vertical, compact ? 6 : 8)
                .background {
                    if isSelected {
                        Capsule(style: .continuous)
                            .fill(palette.cardFill)
                            .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
