//
//  FractionParser.swift
//  Metricize
//

import Foundation

enum FractionParseError: Error, Equatable {
    case empty
    case invalidFormat
    case divisionByZero
    case denominatorTooLarge
}

struct FractionParser {
    private static let defaultMaxDenominator = 64

    /// Parses decimal, simple fraction, or mixed-number strings such as `3 3/32`.
    static func parse(_ input: String) -> Result<Double, FractionParseError> {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .failure(.empty) }

        if let decimal = parseDecimal(trimmed) {
            return .success(decimal)
        }

        let normalized = trimmed
            .replacingOccurrences(of: "  ", with: " ")
            .replacingOccurrences(of: "-", with: " -")

        let parts = normalized.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard !parts.isEmpty else { return .failure(.empty) }

        var sign: Double = 1
        var index = 0
        if parts[0] == "-" {
            sign = -1
            index = 1
            guard index < parts.count else { return .failure(.invalidFormat) }
        }

        switch parts.count - index {
        case 1:
            return parseSingleToken(parts[index]).map { sign * $0 }
        case 2:
            guard
                let whole = parseWholeNumber(parts[index]),
                case .success(let fraction) = parseFractionToken(parts[index + 1])
            else { return .failure(.invalidFormat) }
            return .success(sign * (whole + fraction))
        default:
            return .failure(.invalidFormat)
        }
    }

    /// Formats a decimal as an ordinary mixed fraction (denominators 1 through maxDenominator).
    static func formatFraction(_ value: Double, maxDenominator: Int = defaultMaxDenominator) -> String {
        formatGeneralFractionValue(value, maxDenominator: maxDenominator)
    }

    // MARK: - Private

    private static func parseDecimal(_ string: String) -> Double? {
        let cleaned = string.replacingOccurrences(of: ",", with: "")
        guard !cleaned.contains("/") else { return nil }
        return Double(cleaned)
    }

    private static func parseSingleToken(_ token: String) -> Result<Double, FractionParseError> {
        if let whole = parseWholeNumber(token) {
            return .success(Double(whole))
        }
        return parseFractionToken(token)
    }

    private static func parseWholeNumber(_ token: String) -> Double? {
        let cleaned = token.replacingOccurrences(of: ",", with: "")
        guard let value = Double(cleaned), value.rounded() == value else { return nil }
        return value
    }

    private static func parseFractionToken(_ token: String) -> Result<Double, FractionParseError> {
        let components = token.split(separator: "/").map(String.init)
        guard components.count == 2,
              let numerator = Double(components[0]),
              let denominator = Double(components[1]),
              denominator != 0
        else { return .failure(.invalidFormat) }

        guard denominator <= Double(defaultMaxDenominator) else {
            return .failure(.denominatorTooLarge)
        }
        return .success(numerator / denominator)
    }

    private static func formatGeneralFractionValue(_ value: Double, maxDenominator: Int) -> String {
        signedMixedFraction(
            value,
            numeratorDenominator: bestGeneralRationalApproximation(fractionalPart(of: value), maxDenominator: maxDenominator)
        )
    }

    private static func signedMixedFraction(_ value: Double, numeratorDenominator: (Int, Int)) -> String {
        let sign = value < 0 ? "-" : ""
        var whole = Int(abs(value))
        let fractional = fractionalPart(of: value)

        guard fractional > 0.000_001 else {
            return whole == 0 ? "0" : "\(sign)\(whole)"
        }

        var (numerator, denominator) = numeratorDenominator
        if numerator == denominator {
            whole += 1
            numerator = 0
        }

        if numerator == 0 {
            return whole == 0 ? "0" : "\(sign)\(whole)"
        }

        if whole == 0 {
            return "\(sign)\(numerator)/\(denominator)"
        }
        return "\(sign)\(whole) \(numerator)/\(denominator)"
    }

    private static func fractionalPart(of value: Double) -> Double {
        abs(value) - Double(Int(abs(value)))
    }

    private static func bestGeneralRationalApproximation(_ value: Double, maxDenominator: Int) -> (Int, Int) {
        var bestNumerator = 0
        var bestDenominator = 1
        var bestError = Double.greatestFiniteMagnitude

        for denominator in 1...max(1, maxDenominator) {
            let numerator = Int((value * Double(denominator)).rounded())
            let error = abs(value - Double(numerator) / Double(denominator))
            if error < bestError {
                bestError = error
                bestNumerator = numerator
                bestDenominator = denominator
            }
        }

        let gcd = greatestCommonDivisor(bestNumerator, bestDenominator)
        return (bestNumerator / gcd, bestDenominator / gcd)
    }

    private static func greatestCommonDivisor(_ a: Int, _ b: Int) -> Int {
        var x = abs(a)
        var y = abs(b)
        while y != 0 {
            (x, y) = (y, x % y)
        }
        return max(x, 1)
    }
}
