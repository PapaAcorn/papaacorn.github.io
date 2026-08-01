//
//  ConversionPickerViews.swift
//  Metricize
//

import SwiftUI

struct ConversionCategoryMenu: View {
    @Binding var selection: ConversionCategory

    var body: some View {
        Menu {
            ForEach(ConversionCategory.pickerOrder) { category in
                Button {
                    selection = category
                } label: {
                    ConversionMenuRow(
                        title: category.displayName,
                        isSelected: selection == category
                    )
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
                    ConversionMenuRow(
                        title: unit.displayName,
                        isSelected: selection == unit
                    )
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

private struct ConversionMenuRow: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(title)
            Spacer(minLength: 20)
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
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
