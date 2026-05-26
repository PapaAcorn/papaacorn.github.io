//
//  ConversionEngine.swift
//  Metricize
//

import Foundation

struct ConversionResult: Equatable {
    let numericValue: Double
    let formattedValue: String
    let copyableOutput: String
}

enum ConversionEngineError: Error, Equatable {
    case invalidInput
    case incompatibleUnits
    case outOfRange
}

struct ConversionEngine {
    /// Converts a numeric value between units of the same dimension.
    static func convert(value: Double, from source: ConversionUnit, to target: ConversionUnit, category: ConversionCategory? = nil) -> Result<Double, ConversionEngineError> {
        if let category {
            guard ConversionUnitCompatibility.canConvert(from: source, to: target, category: category) else {
                return .failure(.incompatibleUnits)
            }
        } else if !sharesDimension(source, target) {
            return .failure(.incompatibleUnits)
        }

        if source.primaryCategory == .temperature || target.primaryCategory == .temperature {
            return convertTemperature(value: value, from: source, to: target)
        }

        let sourceCanonical = source.canonicalSibling
        let targetCanonical = target.canonicalSibling

        guard let family = measureFamily(for: sourceCanonical) else {
            return .failure(.incompatibleUnits)
        }
        guard measureFamily(for: targetCanonical) == family else {
            return .failure(.incompatibleUnits)
        }

        let baseValue: Double
        let converted: Double
        switch family {
        case .length:
            baseValue = value * metersPerUnit(sourceCanonical)
            converted = baseValue / metersPerUnit(targetCanonical)
        case .volume:
            baseValue = value * litersPerUnit(sourceCanonical)
            converted = baseValue / litersPerUnit(targetCanonical)
        case .weight:
            baseValue = value * kilogramsPerUnit(sourceCanonical)
            converted = baseValue / kilogramsPerUnit(targetCanonical)
        case .speed:
            baseValue = value * metersPerSecondPerUnit(sourceCanonical)
            converted = baseValue / metersPerSecondPerUnit(targetCanonical)
        }

        return .success(converted)
    }

    private enum MeasureFamily {
        case length, volume, weight, speed
    }

    private static func measureFamily(for unit: ConversionUnit) -> MeasureFamily? {
        if isLengthUnit(unit) { return .length }
        if unit.kitchenMeasureKind == .volume || unit.primaryCategory == .volume { return .volume }
        if unit.kitchenMeasureKind == .weight || unit.primaryCategory == .weight { return .weight }
        if unit.primaryCategory == .speed { return .speed }
        return nil
    }

    static func convert(input: String, from source: ConversionUnit, to target: ConversionUnit, category: ConversionCategory? = nil) -> Result<ConversionResult, ConversionEngineError> {
        let numericValue: Double
        switch parseNumericInput(input, from: source, category: category) {
        case .success(let parsed):
            numericValue = parsed
        case .failure(let error):
            return .failure(error)
        }

        switch convert(value: numericValue, from: source, to: target, category: category) {
        case .success(let converted):
            let formatted = ConversionFormatting.format(value: converted, unit: target)
            let copyable = ConversionFormatting.copyableOutput(value: converted, unit: target)
            return .success(ConversionResult(numericValue: converted, formattedValue: formatted, copyableOutput: copyable))
        case .failure(let error):
            return .failure(error)
        }
    }

    static func parseNumericInput(_ input: String, from source: ConversionUnit, category: ConversionCategory?) -> Result<Double, ConversionEngineError> {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .failure(.invalidInput) }

        if isLengthSource(source, category: category),
           MixedLengthParser.looksLikeMixedLength(trimmed) {
            switch MixedLengthParser.parseToSourceUnitValue(trimmed, sourceUnit: source) {
            case .success(let value):
                return .success(value)
            case .failure:
                break
            }
        }

        if source.acceptsFractions || source == .inches || source == .feet {
            switch FractionParser.parse(trimmed) {
            case .success(let parsed):
                return .success(parsed)
            case .failure:
                guard let decimal = Double(trimmed.replacingOccurrences(of: ",", with: "")) else {
                    return .failure(.invalidInput)
                }
                return .success(decimal)
            }
        }

        guard let decimal = Double(trimmed.replacingOccurrences(of: ",", with: "")) else {
            return .failure(.invalidInput)
        }
        return .success(decimal)
    }

    private static func isLengthSource(_ source: ConversionUnit, category: ConversionCategory?) -> Bool {
        if let category, category == .distance || category == .construction {
            return true
        }
        return source.primaryCategory == .distance || source.primaryCategory == .construction
    }

    // MARK: - Temperature

    private static func convertTemperature(value: Double, from source: ConversionUnit, to target: ConversionUnit) -> Result<Double, ConversionEngineError> {
        let celsius: Double
        switch source {
        case .fahrenheit:
            celsius = (value - 32) * 5 / 9
        case .celsius:
            celsius = value
        case .gasMark:
            celsius = celsiusFromGasMark(value)
        default:
            return .failure(.incompatibleUnits)
        }

        switch target {
        case .fahrenheit:
            return .success(celsius * 9 / 5 + 32)
        case .celsius:
            return .success(celsius)
        case .gasMark:
            return .success(gasMarkFromCelsius(celsius))
        default:
            return .failure(.incompatibleUnits)
        }
    }

    /// UK Gas Mark lookup with interpolation between standard marks.
    private static func celsiusFromGasMark(_ gasMark: Double) -> Double {
        let table: [(gas: Double, celsius: Double)] = [
            (0.25, 110), (0.5, 120), (1, 140), (2, 150), (3, 170),
            (4, 180), (5, 190), (6, 200), (7, 220), (8, 230), (9, 240),
        ]

        if gasMark <= table[0].gas { return table[0].celsius }
        if gasMark >= table[table.count - 1].gas { return table[table.count - 1].celsius }

        for index in 0..<(table.count - 1) {
            let lower = table[index]
            let upper = table[index + 1]
            if gasMark >= lower.gas, gasMark <= upper.gas {
                let ratio = (gasMark - lower.gas) / (upper.gas - lower.gas)
                return lower.celsius + ratio * (upper.celsius - lower.celsius)
            }
        }
        return table[0].celsius
    }

    private static func gasMarkFromCelsius(_ celsius: Double) -> Double {
        let table: [(gas: Double, celsius: Double)] = [
            (0.25, 110), (0.5, 120), (1, 140), (2, 150), (3, 170),
            (4, 180), (5, 190), (6, 200), (7, 220), (8, 230), (9, 240),
        ]

        if celsius <= table[0].celsius { return table[0].gas }
        if celsius >= table[table.count - 1].celsius { return table[table.count - 1].gas }

        for index in 0..<(table.count - 1) {
            let lower = table[index]
            let upper = table[index + 1]
            if celsius >= lower.celsius, celsius <= upper.celsius {
                let ratio = (celsius - lower.celsius) / (upper.celsius - lower.celsius)
                return lower.gas + ratio * (upper.gas - lower.gas)
            }
        }
        return 1
    }

    // MARK: - Unit factors (canonical: meters, liters, kilograms, m/s)

    private static func sharesDimension(_ source: ConversionUnit, _ target: ConversionUnit) -> Bool {
        if source.primaryCategory == target.primaryCategory { return true }
        return isLengthCompatible(source, target)
    }

    static func isLengthCompatible(_ source: ConversionUnit, _ target: ConversionUnit) -> Bool {
        isLengthUnit(source.canonicalSibling) && isLengthUnit(target.canonicalSibling)
    }

    private static func isLengthUnit(_ unit: ConversionUnit) -> Bool {
        unit.primaryCategory == .distance || unit.primaryCategory == .construction
    }

    private static func metersPerUnit(_ unit: ConversionUnit) -> Double {
        switch unit {
        case .inches, .inchesFraction: 0.0254
        case .feet, .feetFraction: 0.3048
        case .yards: 0.9144
        case .miles: 1609.344
        case .millimeters: 0.001
        case .centimeters: 0.01
        case .meters: 1
        case .kilometers: 1000
        default: 1
        }
    }

    private static func litersPerUnit(_ unit: ConversionUnit) -> Double {
        switch unit {
        case .teaspoons: 0.00492892
        case .tablespoons: 0.0147868
        case .milliliters: 0.001
        case .fluidOunces: 0.0295735
        case .cups: 0.236588
        case .pints: 0.473176
        case .quarts: 0.946353
        case .gallons: 3.78541
        case .liters: 1
        default: 1
        }
    }

    private static func kilogramsPerUnit(_ unit: ConversionUnit) -> Double {
        switch unit {
        case .grams: 0.001
        case .ounces: 0.0283495
        case .pounds: 0.453592
        case .stones: 6.35029
        case .kilograms: 1
        default: 1
        }
    }

    private static func metersPerSecondPerUnit(_ unit: ConversionUnit) -> Double {
        switch unit {
        case .milesPerHour: 0.44704
        case .kilometersPerHour: 0.277778
        case .feetPerSecond: 0.3048
        case .metersPerSecond: 1
        default: 1
        }
    }
}
