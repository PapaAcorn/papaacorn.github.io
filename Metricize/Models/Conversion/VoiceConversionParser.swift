//
//  VoiceConversionParser.swift
//  Metricize
//

import Foundation

struct VoiceConversionRequest: Equatable {
    var inputText: String
    var category: ConversionCategory
    var sourceUnit: ConversionUnit
    var targetUnit: ConversionUnit
    var confidence: Double
}

struct VoiceConversionParser {
    private static let numberWords: [String: Double] = [
        "zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
        "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
        "eleven": 11, "twelve": 12, "thirteen": 13, "fourteen": 14, "fifteen": 15,
        "sixteen": 16, "seventeen": 17, "eighteen": 18, "nineteen": 19, "twenty": 20,
        "thirty": 30, "forty": 40, "fifty": 50, "sixty": 60, "seventy": 70,
        "eighty": 80, "ninety": 90, "hundred": 100,
    ]

    private static let fractionWords: [String: (Int, Int)] = [
        "half": (1, 2), "halves": (1, 2),
        "third": (1, 3), "thirds": (1, 3),
        "quarter": (1, 4), "quarters": (1, 4),
        "fourth": (1, 4), "fourths": (1, 4),
        "fifth": (1, 5), "fifths": (1, 5),
        "sixth": (1, 6), "sixths": (1, 6),
        "seventh": (1, 7), "sevenths": (1, 7),
        "eighth": (1, 8), "eighths": (1, 8),
        "ninth": (1, 9), "ninths": (1, 9),
        "tenth": (1, 10), "tenths": (1, 10),
        "eleventh": (1, 11), "elevenths": (1, 11),
        "twelfth": (1, 12), "twelfths": (1, 12),
        "thirteenth": (1, 13), "thirteenths": (1, 13),
        "fourteenth": (1, 14), "fourteenths": (1, 14),
        "fifteenth": (1, 15), "fifteenths": (1, 15),
        "sixteenth": (1, 16), "sixteenths": (1, 16),
        "thirty-second": (1, 32), "thirty second": (1, 32), "thirtyseconds": (1, 32),
        "sixty-fourth": (1, 64), "sixty fourth": (1, 64), "sixtyfourth": (1, 64),
    ]

    private static let unitAliases: [(aliases: [String], unit: ConversionUnit)] = [
        (["fahrenheit", "degrees fahrenheit", "f", "°f"], .fahrenheit),
        (["celsius", "degrees celsius", "centigrade", "c", "°c"], .celsius),
        (["gas mark", "gas"], .gasMark),
        (["inch", "inches", "in"], .inchesFraction),
        (["millimeter", "millimeters", "millimetre", "millimetres", "mm"], .millimeters),
        (["centimeter", "centimeters", "centimetre", "centimetres", "cm"], .centimeters),
        (["foot", "feet", "ft"], .feet),
        (["meter", "meters", "metre", "metres", "m"], .meters),
        (["yard", "yards", "yd"], .yards),
        (["mile", "miles", "mi"], .miles),
        (["kilometer", "kilometers", "kilometre", "kilometres", "km"], .kilometers),
        (["teaspoon", "teaspoons", "tsp"], .teaspoons),
        (["tablespoon", "tablespoons", "tbsp"], .tablespoons),
        (["fluid ounce", "fluid ounces", "fl oz", "floz"], .fluidOunces),
        (["milliliter", "milliliters", "millilitre", "millilitres", "ml"], .milliliters),
        (["cup", "cups"], .cups),
        (["liter", "liters", "litre", "litres", "l"], .liters),
        (["pint", "pints", "pt"], .pints),
        (["quart", "quarts", "qt"], .quarts),
        (["gallon", "gallons", "gal"], .gallons),
        (["ounce", "ounces", "oz"], .ounces),
        (["gram", "grams", "g"], .grams),
        (["pound", "pounds", "lb", "lbs"], .pounds),
        (["kilogram", "kilograms", "kg"], .kilograms),
        (["stone", "stones", "st"], .stones),
        (["mile per hour", "miles per hour", "mph"], .milesPerHour),
        (["kilometer per hour", "kilometers per hour", "km per hour", "km/h", "kph"], .kilometersPerHour),
        (["foot per second", "feet per second", "ft/s", "ft per second"], .feetPerSecond),
        (["meter per second", "meters per second", "m/s", "m per second"], .metersPerSecond),
    ]

    static func parse(_ transcript: String) -> VoiceConversionRequest? {
        let normalized = normalize(transcript)
        guard !normalized.isEmpty else { return nil }

        let sourceUnit = findUnit(in: normalized, role: .source)
        let targetUnit = findUnit(in: normalized, role: .target)
        let valueText = extractValueText(from: normalized)
            ?? extractValueBeforeUnit(in: normalized, unit: sourceUnit.unit)

        guard let source = sourceUnit.unit ?? inferUnit(from: normalized, categoryHint: sourceUnit.category),
              let target = targetUnit.unit ?? defaultTarget(for: source)
        else { return nil }

        let category = resolvedCategory(for: source, explicit: sourceUnit.category)
        let confidence = min(sourceUnit.confidence, targetUnit.confidence, valueText == nil ? 0.4 : 0.85)

        return VoiceConversionRequest(
            inputText: valueText ?? "",
            category: category,
            sourceUnit: source,
            targetUnit: target,
            confidence: confidence
        )
    }

    // MARK: - Private

    private enum UnitRole {
        case source, target
    }

    private static func normalize(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "°", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " into ", with: " to ")
            .replacingOccurrences(of: " in to ", with: " to ")
            .replacingOccurrences(of: "convert ", with: "")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func findUnit(in text: String, role: UnitRole) -> (unit: ConversionUnit?, category: ConversionCategory?, confidence: Double) {
        if role == .target, let range = text.range(of: " to ") {
            let segment = String(text[range.upperBound...])
            if let match = matchUnit(in: segment) {
                return (match, match.category, 0.9)
            }
        }

        if role == .source {
            if let range = text.range(of: " from ") {
                var segment = String(text[range.upperBound...])
                if let toRange = segment.range(of: " to ") {
                    segment = String(segment[..<toRange.lowerBound])
                }
                if let match = matchUnit(in: segment) {
                    return (match, match.category, 0.9)
                }
            }

            if let toRange = text.range(of: " to ") {
                let beforeTarget = String(text[..<toRange.lowerBound])
                if let match = matchUnit(in: beforeTarget) {
                    return (match, match.category, 0.85)
                }
            }
        }

        return (nil, nil, 0.5)
    }

    private static func extractValueBeforeUnit(in text: String, unit: ConversionUnit?) -> String? {
        guard let unit else { return nil }
        let aliases = unitAliases.first(where: { $0.unit == unit })?.aliases ?? []
        for alias in aliases.sorted(by: { $0.count > $1.count }) {
            guard let range = text.range(of: alias) else { continue }
            let prefix = String(text[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            if let spoken = parseSpokenNumber(prefix) { return spoken }
            if let lastToken = prefix.split(separator: " ").last.map(String.init),
               let spoken = parseSpokenNumber(lastToken) {
                return spoken
            }
        }
        return nil
    }

    private static func matchUnit(in text: String) -> ConversionUnit? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        for entry in unitAliases.sorted(by: { $0.aliases[0].count > $1.aliases[0].count }) {
            for alias in entry.aliases {
                if containsWholePhrase(trimmed, phrase: alias) {
                    return entry.unit
                }
            }
        }
        return nil
    }

    private static func containsWholePhrase(_ text: String, phrase: String) -> Bool {
        guard !phrase.isEmpty else { return false }
        if text == phrase { return true }
        if text.hasPrefix(phrase + " ") { return true }
        if text.hasSuffix(" " + phrase) { return true }
        if text.contains(" " + phrase + " ") { return true }
        return false
    }

    private static func inferUnit(from text: String, categoryHint: ConversionCategory?) -> ConversionUnit? {
        if let unit = matchUnit(in: text) { return unit }
        guard let categoryHint else { return nil }
        return categoryHint.units.first
    }

    private static func resolvedCategory(for unit: ConversionUnit, explicit: ConversionCategory?) -> ConversionCategory {
        if unit == .teaspoons || unit == .tablespoons { return .kitchen }
        if unit.kitchenMeasureKind != nil, explicit == nil {
            return .kitchen
        }
        return unit.primaryCategory
    }

    private static func defaultTarget(for source: ConversionUnit) -> ConversionUnit? {
        switch source {
        case .fahrenheit: .celsius
        case .celsius: .fahrenheit
        case .gasMark: .celsius
        case .teaspoons, .tablespoons: .milliliters
        case .inches, .inchesFraction, .feet, .feetFraction: .millimeters
        case .millimeters, .centimeters: .inchesFraction
        case .meters, .yards: .meters
        case .feet: .meters
        case .miles: .kilometers
        case .kilometers: .miles
        case .fluidOunces, .cups, .pints, .quarts, .gallons: .milliliters
        case .milliliters, .liters: .fluidOunces
        case .ounces: .grams
        case .grams: .ounces
        case .pounds: .kilograms
        case .kilograms: .pounds
        case .stones: .kilograms
        case .milesPerHour: .kilometersPerHour
        case .kilometersPerHour: .milesPerHour
        case .feetPerSecond: .metersPerSecond
        case .metersPerSecond: .feetPerSecond
        }
    }

    private static func extractValueText(from text: String) -> String? {
        if let fromRange = text.range(of: " from ") {
            let beforeFrom = String(text[..<fromRange.lowerBound]).trimmingCharacters(in: .whitespaces)
            if !beforeFrom.isEmpty {
                return parseSpokenNumber(beforeFrom) ?? beforeFrom
            }
        }

        let digitPattern = #"[\d]+(?:\.\d+)?(?:\s+\d+\s*/\s*\d+)?"#
        if let match = text.range(of: digitPattern, options: .regularExpression) {
            return String(text[match])
        }

        let wordsBeforeFrom = text.components(separatedBy: " from ").first ?? text
        return parseSpokenNumber(wordsBeforeFrom)
    }

    private static let spokenDenominators: [String: Int] = [
        "second": 2, "seconds": 2,
        "third": 3, "thirds": 3,
        "fourth": 4, "fourths": 4,
        "fifth": 5, "fifths": 5,
        "sixth": 6, "sixths": 6,
        "seventh": 7, "sevenths": 7,
        "eighth": 8, "eighths": 8,
        "ninth": 9, "ninths": 9,
        "tenth": 10, "tenths": 10,
        "eleventh": 11, "elevenths": 11,
        "twelfth": 12, "twelfths": 12,
        "thirteenth": 13, "thirteenths": 13,
        "fourteenth": 14, "fourteenths": 14,
        "fifteenth": 15, "fifteenths": 15,
        "sixteenth": 16, "sixteenths": 16,
        "thirty second": 32, "thirty seconds": 32,
        "sixty fourth": 64, "sixty fourths": 64,
    ]

    static func parseSpokenNumber(_ text: String) -> String? {
        let lowered = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !lowered.isEmpty else { return nil }

        if let decimal = Double(lowered.replacingOccurrences(of: " ", with: "")) {
            return String(decimal)
        }

        if lowered.contains(" and ") {
            let parts = lowered.components(separatedBy: " and ")
            if parts.count == 2,
               let whole = wordNumber(parts[0]),
               let fraction = parseFractionPhrase(parts[1]) {
                return "\(Int(whole)) \(fraction)"
            }
        }

        if let fraction = parseFractionPhrase(lowered) {
            return fraction
        }

        return wordNumber(lowered).map { String(format: "%.0f", $0) }
    }

    private static func wordNumber(_ text: String) -> Double? {
        let tokens = text
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map(String.init)
        guard !tokens.isEmpty else { return nil }

        var total: Double = 0
        for token in tokens {
            if token == "a" || token == "an" { continue }
            if let value = numberWords[token] {
                total += value
            } else if let numeric = Double(token) {
                total = numeric
            } else {
                return nil
            }
        }
        return total > 0 ? total : nil
    }

    private static func parseFractionPhrase(_ text: String) -> String? {
        let normalized = text
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if normalized.contains("/") { return normalized }

        if let pair = fractionWords[normalized] {
            return "\(pair.0)/\(pair.1)"
        }

        let tokens = normalized.split(separator: " ").map(String.init)
        guard !tokens.isEmpty else { return nil }

        if tokens.count == 1, let pair = fractionWords[tokens[0]] {
            return "\(pair.0)/\(pair.1)"
        }

        if tokens.count >= 2 {
            let tail = tokens.suffix(2).joined(separator: " ")
            if let denominator = spokenDenominators[tail] {
                let head = tokens.dropLast(2)
                let numeratorToken = head.last ?? "one"
                let numerator = Int(numberWords[numeratorToken] ?? 1)
                return "\(numerator)/\(denominator)"
            }
            let singleTail = tokens.last ?? ""
            if let pair = fractionWords[singleTail] {
                let numeratorToken = tokens.dropLast().last ?? "one"
                let numerator = Int(numberWords[numeratorToken] ?? Double(pair.0))
                return "\(numerator)/\(pair.1)"
            }
        }

        return nil
    }
}
