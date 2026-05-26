//
//  UnitCalculatorViewModel.swift
//  Metricize
//

import Foundation
import Observation

@Observable
final class UnitCalculatorViewModel {
    var category: ConversionCategory {
        didSet { reconcileUnitAfterCategoryChange() }
    }

    var unit: ConversionUnit
    var display: String = "0"
    var displayMode: DisplayMode = .decimal

    private var accumulator: Double?
    private var pendingOperation: Operation?
    private var enteringSecondOperand = false

    enum Operation: String {
        case add, subtract, multiply, divide

        var symbol: String {
            switch self {
            case .add: "+"
            case .subtract: "−"
            case .multiply: "×"
            case .divide: "÷"
            }
        }
    }

    enum DisplayMode {
        case decimal
        case fraction
    }

    init(category: ConversionCategory, unit: ConversionUnit) {
        self.category = category
        self.unit = unit
    }

    var availableUnits: [ConversionUnit] {
        category.units
    }

    var supportsFractionEntry: Bool {
        unit.acceptsFractions
            || unit == .inches
            || unit == .feet
            || category == .construction
    }

    var supportsFractionToggle: Bool {
        supportsFractionEntry
    }

    var fractionToggleLabel: String {
        displayMode == .fraction ? "1.2" : "a/b"
    }

    var numericValue: Double? {
        parseDisplay(display)
    }

    var hasPendingResult: Bool {
        guard let value = numericValue else { return false }
        return abs(value) > 0.000_001 || display.contains("/")
    }

    var converterValue: String {
        Self.formatForConverter(display)
    }

    func appendDigit(_ digit: String) {
        if enteringSecondOperand {
            display = digit
            enteringSecondOperand = false
            displayMode = .decimal
            return
        }

        if display == "0" {
            display = digit
        } else {
            display += digit
        }
    }

    func appendDecimal() {
        if enteringSecondOperand {
            display = "0."
            enteringSecondOperand = false
            displayMode = .decimal
            return
        }

        displayMode = .decimal

        let lastSegment = display.split(separator: " ").last.map(String.init) ?? display
        guard !lastSegment.contains(".") else { return }
        if display == "0" {
            display = "0."
        } else {
            display += "."
        }
    }

    func appendSpace() {
        if enteringSecondOperand {
            enteringSecondOperand = false
        }
        guard supportsFractionEntry else { return }
        guard !display.isEmpty, !display.hasSuffix(" ") else { return }
        display += " "
    }

    func appendSlash() {
        if enteringSecondOperand {
            enteringSecondOperand = false
        }
        guard supportsFractionEntry else { return }
        let lastSegment = display.split(separator: " ").last.map(String.init) ?? display
        guard !lastSegment.contains("/") else { return }
        if display.isEmpty { display = "0" }
        display += "/"
    }

    func toggleFractionDecimal() {
        guard supportsFractionToggle, let value = numericValue else { return }
        switch displayMode {
        case .decimal:
            displayMode = .fraction
            display = formatAsFraction(value)
        case .fraction:
            displayMode = .decimal
            display = Self.formatForDisplay(value)
        }
        enteringSecondOperand = false
    }

    func toggleSign() {
        guard let value = numericValue else { return }
        display = formatDisplayValue(-value)
        enteringSecondOperand = false
    }

    func applyPercent() {
        guard let value = numericValue else { return }
        display = formatDisplayValue(value / 100)
        enteringSecondOperand = false
    }

    func applyOperation(_ operation: Operation) {
        let current = numericValue ?? 0

        if let acc = accumulator, let pending = pendingOperation, !enteringSecondOperand {
            let result = Self.evaluate(acc, pending, current)
            display = formatDisplayValue(result)
            accumulator = result
        } else {
            accumulator = current
        }

        pendingOperation = operation
        enteringSecondOperand = true
    }

    func equals() {
        guard let acc = accumulator, let pending = pendingOperation else { return }
        let current = numericValue ?? 0
        display = formatDisplayValue(Self.evaluate(acc, pending, current))
        accumulator = nil
        pendingOperation = nil
        enteringSecondOperand = false
    }

    func clear() {
        display = "0"
        displayMode = .decimal
        accumulator = nil
        pendingOperation = nil
        enteringSecondOperand = false
    }

    func backspace() {
        guard !enteringSecondOperand else { return }
        guard display.count > 1 else {
            display = "0"
            return
        }
        display.removeLast()
        if display == "-" || display.trimmingCharacters(in: .whitespaces).isEmpty {
            display = "0"
        }
    }

    private func formatDisplayValue(_ value: Double) -> String {
        if displayMode == .fraction {
            return formatAsFraction(value)
        }
        return Self.formatForDisplay(value)
    }

    private func formatAsFraction(_ value: Double) -> String {
        switch unit {
        case .feetFraction, .feet:
            return FractionParser.formatFeetFraction(value)
        case .inchesFraction, .inches:
            return FractionParser.formatInchesFraction(value)
        default:
            return FractionParser.formatInchesFraction(value)
        }
    }

    private func reconcileUnitAfterCategoryChange() {
        let units = availableUnits
        if !units.contains(unit) {
            unit = units.first ?? .inches
        }
    }

    private func parseDisplay(_ text: String) -> Double? {
        switch FractionParser.parse(text) {
        case .success(let value):
            return value
        case .failure:
            return Double(text)
        }
    }

    private static func evaluate(_ lhs: Double, _ operation: Operation, _ rhs: Double) -> Double {
        switch operation {
        case .add: lhs + rhs
        case .subtract: lhs - rhs
        case .multiply: lhs * rhs
        case .divide: rhs == 0 ? 0 : lhs / rhs
        }
    }

    private static func formatForDisplay(_ value: Double) -> String {
        if value.isNaN || value.isInfinite { return "0" }
        if value.rounded() == value, abs(value) < 1_000_000_000 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.8g", value)
    }

    static func formatForConverter(_ text: String) -> String {
        switch FractionParser.parse(text) {
        case .success(let value):
            if text.contains("/") || text.contains(" ") {
                return text.trimmingCharacters(in: .whitespaces)
            }
            return formatForDisplay(value)
        case .failure:
            return text.trimmingCharacters(in: .whitespaces)
        }
    }
}
