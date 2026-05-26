//
//  ConversionPickerViews.swift
//  Metricize
//

import SwiftUI

struct ConversionCategoryMenu: View {
    @Environment(\.metricPalette) private var palette
    @Binding var selection: ConversionCategory

    var body: some View {
        Menu {
            ForEach(Array(ConversionCategory.pickerSections.enumerated()), id: \.offset) { index, section in
                if index > 0 {
                    Divider()
                }
                ForEach(section) { category in
                    Button {
                        selection = category
                    } label: {
                        if selection == category {
                            Label(category.displayName, systemImage: "checkmark")
                        } else {
                            Text(category.displayName)
                        }
                    }
                }
            }
        } label: {
            ConversionPickerLabel(title: "Category", value: selection.displayName)
        }
        .accessibilityLabel("Category")
        .accessibilityValue(selection.displayName)
    }
}

struct ConversionUnitMenu: View {
    @Environment(\.metricPalette) private var palette

    let title: String
    let units: [ConversionUnit]
    @Binding var selection: ConversionUnit
    var sourceUnit: ConversionUnit?
    var category: ConversionCategory
    var showsCompatibility: Bool = false

    var body: some View {
        Menu {
            ForEach(units) { unit in
                let compatible = isCompatible(unit)
                Button {
                    selection = unit
                } label: {
                    if selection == unit {
                        Label(unit.displayName, systemImage: "checkmark")
                    } else {
                        Text(unit.displayName)
                    }
                }
                .disabled(showsCompatibility && !compatible)
            }
        } label: {
            ConversionPickerLabel(title: title, value: selection.displayName)
        }
        .accessibilityLabel(title)
        .accessibilityValue(selection.displayName)
    }

    private func isCompatible(_ unit: ConversionUnit) -> Bool {
        guard showsCompatibility, let sourceUnit else { return true }
        if unit == sourceUnit { return false }
        return ConversionUnitCompatibility.canConvert(from: sourceUnit, to: unit, category: category)
    }
}

private struct ConversionPickerLabel: View {
    @Environment(\.metricPalette) private var palette

    let title: String
    let value: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.caption2.weight(.semibold))
                    .tracking(0.8)
                    .foregroundStyle(palette.textTertiary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.textTertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.chipFill)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(palette.chipStroke, lineWidth: 1)
                }
        }
        .contentShape(Rectangle())
    }
}

struct CalculatorLaunchButton: View {
    @Environment(\.metricPalette) private var palette
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Calculator")
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
                .frame(minWidth: 96)
                .foregroundStyle(palette.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            .background {
                Capsule(style: .continuous)
                    .fill(palette.chipFill)
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(palette.chipStroke, lineWidth: 1)
                    }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open calculator")
    }
}
