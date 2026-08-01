//
//  ConversionFormatting.swift
//  Metricize
//

import Foundation

enum ConversionFormatting {
    enum ValueDisplayMode {
        case decimal
        case fraction
    }

    static func defaultDisplayMode(for unit: ConversionUnit, category: ConversionCategory) -> ValueDisplayMode {
        category == .distance && unit.isImperialLength ? .fraction : .decimal
    }

    static func effectiveDisplayMode(
        _ requested: ValueDisplayMode,
        unit: ConversionUnit,
        category: ConversionCategory
    ) -> ValueDisplayMode {
        category == .distance && unit.isImperialLength ? requested : .decimal
    }

    static func formatResult(
        value: Double,
        unit: ConversionUnit,
        category: ConversionCategory,
        displayMode: ValueDisplayMode
    ) -> String {
        format(
            value: value,
            unit: unit,
            category: category,
            displayMode: displayMode,
            isInput: false
        )
    }

    static func format(
        value: Double,
        unit: ConversionUnit,
        category: ConversionCategory? = nil,
        displayMode: ValueDisplayMode = .decimal,
        isInput: Bool = false
    ) -> String {
        let resolvedCategory = category ?? unit.primaryCategory
        let effectiveMode = effectiveDisplayMode(displayMode, unit: unit, category: resolvedCategory)

        if effectiveMode == .fraction, unit.isImperialLength {
            return formatGeneralFraction(value: value)
        }

        switch unit {
        case .fahrenheit, .celsius:
            return formatNumber(value, decimals: 1)
        case .gasMark:
            return formatGasMark(value)
        case .millimeters, .centimeters:
            return formatNumber(value, decimals: 2)
        case .inches, .feet, .meters, .yards, .miles, .kilometers:
            return formatNumber(value, decimals: sensibleDistanceDecimals(unit))
        case .teaspoons, .tablespoons, .fluidOunces, .milliliters, .cups, .liters, .pints, .quarts, .gallons:
            return formatNumber(value, decimals: sensibleVolumeDecimals(unit))
        case .ounces, .grams, .pounds, .kilograms, .stones:
            return formatNumber(value, decimals: sensibleMassDecimals(unit))
        case .milesPerHour, .kilometersPerHour, .feetPerSecond, .metersPerSecond:
            return formatNumber(value, decimals: 2)
        }
    }

    static func formatInputFraction(value: Double, unit: ConversionUnit, category: ConversionCategory) -> String {
        if category == .distance, unit.isImperialLength {
            return formatGeneralFraction(value: value)
        }
        return formatGeneralFraction(value: value)
    }

    static func formatGeneralFraction(value: Double) -> String {
        FractionParser.formatFraction(value)
    }

    static func formatForInputSwap(
        value: Double,
        unit: ConversionUnit,
        category: ConversionCategory,
        displayMode: ValueDisplayMode
    ) -> String {
        switch effectiveDisplayMode(displayMode, unit: unit, category: category) {
        case .fraction:
            return formatInputFraction(value: value, unit: unit, category: category)
        case .decimal:
            return formatDecimal(value: value)
        }
    }

    static func formatDecimal(value: Double) -> String {
        if value.isNaN || value.isInfinite { return "0" }
        if value.rounded() == value, abs(value) < 1_000_000_000 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.8g", value)
    }

    static func displayLine(
        value: Double,
        unit: ConversionUnit,
        category: ConversionCategory,
        displayMode: ValueDisplayMode,
        isInput: Bool = false
    ) -> String {
        let formatted = format(
            value: value,
            unit: unit,
            category: category,
            displayMode: displayMode,
            isInput: isInput
        )
        return "\(formatted) \(unit.symbol)"
    }

    static func copyableOutput(
        value: Double,
        unit: ConversionUnit,
        category: ConversionCategory? = nil,
        displayMode: ValueDisplayMode = .decimal
    ) -> String {
        let resolvedCategory = category ?? unit.primaryCategory
        return displayLine(
            value: value,
            unit: unit,
            category: resolvedCategory,
            displayMode: displayMode
        )
    }

    static func format(value: Double, unit: ConversionUnit, isInput: Bool = false) -> String {
        format(value: value, unit: unit, category: unit.primaryCategory, isInput: isInput)
    }

    static func copyableOutput(value: Double, unit: ConversionUnit) -> String {
        copyableOutput(value: value, unit: unit, category: unit.primaryCategory)
    }

    // MARK: - Private

    private static func formatNumber(_ value: Double, decimals: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = decimals
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(decimals)f", value)
    }

    private static func formatGasMark(_ value: Double) -> String {
        if abs(value - value.rounded()) < 0.05 {
            let rounded = Int(value.rounded())
            if rounded == 0 { return "Off" }
            return "\(rounded)"
        }
        if value < 0.5 { return "¼" }
        if value < 0.75 { return "½" }
        return formatNumber(value, decimals: 1)
    }

    private static func sensibleDistanceDecimals(_ unit: ConversionUnit) -> Int {
        switch unit {
        case .inches: 3
        case .feet, .yards, .meters: 2
        case .miles, .kilometers: 2
        default: 2
        }
    }

    private static func sensibleVolumeDecimals(_ unit: ConversionUnit) -> Int {
        switch unit {
        case .milliliters, .teaspoons: 0
        case .tablespoons: 1
        case .fluidOunces, .cups, .pints, .quarts: 2
        case .liters, .gallons: 2
        default: 2
        }
    }

    private static func sensibleMassDecimals(_ unit: ConversionUnit) -> Int {
        switch unit {
        case .grams: 0
        case .ounces: 1
        case .pounds, .kilograms, .stones: 2
        default: 2
        }
    }
}
