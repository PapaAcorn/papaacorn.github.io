//
//  MixedLengthParser.swift
//  Metricize
//

import Foundation

enum MixedLengthParseError: Error, Equatable {
    case empty
    case invalidFormat
}

struct MixedLengthParser {
    private static let unitAliases: [(aliases: [String], unit: ConversionUnit)] = [
        (["millimeter", "millimeters", "millimetre", "millimetres", "mm"], .millimeters),
        (["centimeter", "centimeters", "centimetre", "centimetres", "cm"], .centimeters),
        (["inch", "inches", "in", "\""], .inches),
        (["foot", "feet", "ft", "'"], .feet),
        (["yard", "yards", "yd"], .yards),
        (["mile", "miles", "mi"], .miles),
        (["meter", "meters", "metre", "metres", "m"], .meters),
        (["kilometer", "kilometers", "kilometre", "kilometres", "km"], .kilometers),
    ]

    static func looksLikeMixedLength(_ input: String) -> Bool {
        let lowered = input.lowercased()
        if lowered.contains(",") { return true }
        if lowered.contains("'") || lowered.contains("\"") { return true }
        for entry in unitAliases {
            for alias in entry.aliases where alias.count > 1 {
                if containsWholeWord(lowered, word: alias) { return true }
            }
        }
        return false
    }

    /// Parses expressions such as `5 ft 10 in`, `5 feet, 10 inches`, or `5, 10` (feet + inches).
    static func parseToMeters(_ input: String, defaultUnit: ConversionUnit) -> Result<Double, MixedLengthParseError> {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .failure(.empty) }

        if trimmed.contains(",") {
            let parts = trimmed
                .split(separator: ",")
                .map { String($0).trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }

            if parts.count == 2,
               !parts.contains(where: { segmentHasUnitWord($0) }),
               isFeetInchesDefault(defaultUnit.canonicalSibling) {
                return parseFeetInchesPair(feetPart: parts[0], inchesPart: parts[1])
            }

            var totalMeters = 0.0
            for part in parts {
                switch parseSegment(part, defaultUnit: defaultUnit.canonicalSibling) {
                case .success(let meters):
                    totalMeters += meters
                case .failure:
                    return .failure(.invalidFormat)
                }
            }
            return .success(totalMeters)
        }

        let segments = tokenizeSegments(trimmed)
        guard !segments.isEmpty else { return .failure(.invalidFormat) }

        var totalMeters = 0.0
        for segment in segments {
            switch parseSegment(segment, defaultUnit: defaultUnit.canonicalSibling) {
            case .success(let meters):
                totalMeters += meters
            case .failure:
                return .failure(.invalidFormat)
            }
        }
        return .success(totalMeters)
    }

    static func parseToSourceUnitValue(_ input: String, sourceUnit: ConversionUnit) -> Result<Double, MixedLengthParseError> {
        switch parseToMeters(input, defaultUnit: sourceUnit) {
        case .success(let meters):
            let factor = metersPerUnit(sourceUnit.canonicalSibling)
            guard factor > 0 else { return .failure(.invalidFormat) }
            return .success(meters / factor)
        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - Private

    private static func parseFeetInchesPair(feetPart: String, inchesPart: String) -> Result<Double, MixedLengthParseError> {
        guard
            let feet = parseNumericValue(feetPart),
            let inches = parseNumericValue(inchesPart)
        else { return .failure(.invalidFormat) }

        let meters = feet * metersPerUnit(.feet) + inches * metersPerUnit(.inches)
        return .success(meters)
    }

    private static func tokenizeSegments(_ input: String) -> [String] {
        let tokens = input
            .replacingOccurrences(of: " and ", with: " ")
            .split(separator: " ", omittingEmptySubsequences: true)
            .map(String.init)

        var segments: [String] = []
        var buffer: [String] = []

        for token in tokens {
            if unitForToken(token) != nil {
                buffer.append(token)
                segments.append(buffer.joined(separator: " "))
                buffer = []
            } else {
                buffer.append(token)
            }
        }

        if !buffer.isEmpty {
            segments.append(buffer.joined(separator: " "))
        }
        return segments
    }

    private static func parseSegment(_ segment: String, defaultUnit: ConversionUnit) -> Result<Double, MixedLengthParseError> {
        let cleaned = segment.trimmingCharacters(in: .whitespaces)
        guard !cleaned.isEmpty else { return .failure(.invalidFormat) }

        if let unit = unitForPhrase(cleaned) {
            let numericText = stripUnitWords(from: cleaned)
            guard let value = parseNumericValue(numericText) else { return .failure(.invalidFormat) }
            return .success(value * metersPerUnit(unit))
        }

        guard let value = parseNumericValue(cleaned) else { return .failure(.invalidFormat) }
        return .success(value * metersPerUnit(defaultUnit))
    }

    private static func parseNumericValue(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        if let value = try? FractionParser.parse(trimmed).get() { return value }
        return Double(trimmed.replacingOccurrences(of: ",", with: ""))
    }

    private static func segmentHasUnitWord(_ segment: String) -> Bool {
        unitForPhrase(segment) != nil
    }

    private static func phraseHasUnitWord(_ phrase: String) -> Bool {
        unitForPhrase(phrase) != nil
    }

    private static func isFeetInchesDefault(_ unit: ConversionUnit) -> Bool {
        switch unit {
        case .feet, .feetFraction, .inches, .inchesFraction:
            return true
        default:
            return false
        }
    }

    private static func unitForPhrase(_ phrase: String) -> ConversionUnit? {
        let lowered = phrase.lowercased().trimmingCharacters(in: .whitespaces)
        for entry in unitAliases {
            for alias in entry.aliases.sorted(by: { $0.count > $1.count }) {
                if lowered == alias || lowered.hasSuffix(" " + alias) {
                    return entry.unit
                }
            }
        }
        return nil
    }

    private static func unitForToken(_ token: String) -> ConversionUnit? {
        unitForPhrase(token)
    }

    private static func stripUnitWords(from phrase: String) -> String {
        guard let unit = unitForPhrase(phrase) else {
            return phrase.trimmingCharacters(in: .whitespaces)
        }

        var lowered = phrase.lowercased().trimmingCharacters(in: .whitespaces)
        let aliases = unitAliases.first(where: { $0.unit == unit })?.aliases.sorted(by: { $0.count > $1.count }) ?? []
        for alias in aliases {
            if lowered == alias {
                return ""
            }
            if lowered.hasSuffix(" " + alias) {
                return String(lowered.dropLast(alias.count + 1)).trimmingCharacters(in: .whitespaces)
            }
        }
        return lowered
    }

    private static func containsWholeWord(_ text: String, word: String) -> Bool {
        guard !word.isEmpty else { return false }
        if text == word { return true }
        if text.hasPrefix(word + " ") { return true }
        if text.hasSuffix(" " + word) { return true }
        if text.contains(" " + word + " ") { return true }
        return false
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
}
