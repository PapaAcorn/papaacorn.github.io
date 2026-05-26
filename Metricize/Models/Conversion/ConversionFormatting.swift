//
//  ConversionFormatting.swift
//  Metricize
//

import Foundation

enum ConversionFormatting {
    static func format(value: Double, unit: ConversionUnit, isInput: Bool = false) -> String {
        switch unit {
        case .fahrenheit, .celsius:
            return formatNumber(value, decimals: 1)
        case .gasMark:
            return formatGasMark(value)
        case .millimeters:
            return formatNumber(value, decimals: 2)
        case .centimeters:
            return formatNumber(value, decimals: 2)
        case .inches, .feet, .meters, .yards, .miles, .kilometers:
            return formatNumber(value, decimals: sensibleDistanceDecimals(unit))
        case .inchesFraction:
            if isInput { return FractionParser.formatInchesFraction(value) }
            return FractionParser.formatInchesFraction(value)
        case .feetFraction:
            return FractionParser.formatFeetFraction(value)
        case .teaspoons, .tablespoons, .fluidOunces, .milliliters, .cups, .liters, .pints, .quarts, .gallons:
            return formatNumber(value, decimals: sensibleVolumeDecimals(unit))
        case .ounces, .grams, .pounds, .kilograms, .stones:
            return formatNumber(value, decimals: sensibleMassDecimals(unit))
        case .milesPerHour, .kilometersPerHour, .feetPerSecond, .metersPerSecond:
            return formatNumber(value, decimals: 2)
        }
    }

    static func displayLine(value: Double, unit: ConversionUnit, isInput: Bool = false) -> String {
        let formatted = format(value: value, unit: unit, isInput: isInput)
        return "\(formatted) \(unit.symbol)"
    }

    static func copyableOutput(value: Double, unit: ConversionUnit) -> String {
        displayLine(value: value, unit: unit)
    }

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
