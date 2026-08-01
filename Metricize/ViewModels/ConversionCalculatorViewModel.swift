//
//  ConversionCalculatorViewModel.swift
//  Metricize
//

import Foundation
import Observation

@Observable
final class ConversionCalculatorViewModel {
    typealias ValueDisplayMode = ConversionFormatting.ValueDisplayMode

    var category: ConversionCategory = .distance {
        didSet { reconcileUnitsAfterCategoryChange() }
    }

    var sourceUnit: ConversionUnit = .inches
    var targetUnit: ConversionUnit = .millimeters
    var inputText: String = ""
    var result: ConversionResult?
    var inputError: String?
    var inputDisplayMode: ValueDisplayMode = .decimal
    var outputDisplayMode: ValueDisplayMode = .decimal
    private var outputDisplayModeOverridden = false

    var availableUnits: [ConversionUnit] {
        category.units
    }

    var inputPlaceholder: String {
        "Enter value or fraction"
    }

    static let fractionDecimalToggleLabel = "Frac/Dec"

    var fractionToggleLabel: String {
        Self.fractionDecimalToggleLabel
    }

    var outputFractionToggleLabel: String {
        Self.fractionDecimalToggleLabel
    }

    var showsOutputFormatToggle: Bool { true }

    var sourceDisplayText: String {
        guard !inputText.isEmpty else { return "—" }
        return "\(inputText) \(sourceUnit.symbol)"
    }

    var resultDisplayText: String {
        result?.copyableOutput ?? "—"
    }

    func isTargetCompatible(_ unit: ConversionUnit) -> Bool {
        ConversionUnitCompatibility.canConvert(from: sourceUnit, to: unit, category: category)
    }

    func appendInput(_ token: String) {
        inputError = nil
        if token == "/" {
            let lastSegment = inputText.split(separator: " ").last.map(String.init) ?? inputText
            guard !lastSegment.contains("/") else { return }
            if inputText.isEmpty { inputText = "0" }
            inputText += "/"
        } else if token == " " {
            if inputText.isEmpty || inputText.hasSuffix(" ") { return }
            inputText += " "
        } else if token == "." {
            let lastSegment = inputText.split(separator: " ").last.map(String.init) ?? inputText
            guard !lastSegment.contains(".") else { return }
            if inputText.isEmpty { inputText = "0" }
            inputText += "."
            inputDisplayMode = .decimal
        } else {
            inputText += token
        }
        performConversion()
    }

    func backspace() {
        guard !inputText.isEmpty else { return }
        inputText.removeLast()
        inputError = nil
        performConversion()
    }

    func clearInput() {
        inputText = ""
        inputError = nil
        result = nil
    }

    func toggleInputFractionDecimal() {
        guard let value = parsedInputValue else { return }
        switch inputDisplayMode {
        case .decimal:
            inputDisplayMode = .fraction
            inputText = ConversionFormatting.formatInputFraction(
                value: value,
                unit: sourceUnit,
                category: category
            )
        case .fraction:
            inputDisplayMode = .decimal
            inputText = ConversionFormatting.formatDecimal(value: value)
        }
        performConversion()
    }

    func toggleOutputFractionDecimal() {
        outputDisplayModeOverridden = true
        outputDisplayMode = outputDisplayMode == .fraction ? .decimal : .fraction
        performConversion()
    }

    func swapUnits() {
        guard isTargetCompatible(sourceUnit) || ConversionUnitCompatibility.canConvert(
            from: targetUnit,
            to: sourceUnit,
            category: category
        ) else { return }

        let previousSource = sourceUnit
        sourceUnit = targetUnit
        targetUnit = previousSource

        if let currentResult = result {
            inputText = ConversionFormatting.formatForInputSwap(
                value: currentResult.numericValue,
                unit: sourceUnit,
                category: category,
                displayMode: inputDisplayMode
            )
        }
        reconcileTargetUnit()
        applyDefaultOutputDisplayMode()
        performConversion()
    }

    func selectCategory(_ newCategory: ConversionCategory) {
        category = newCategory
    }

    func selectSourceUnit(_ unit: ConversionUnit) {
        sourceUnit = unit
        reconcileTargetUnit()
        applyDefaultOutputDisplayMode()
        performConversion()
    }

    func selectTargetUnit(_ unit: ConversionUnit) {
        guard isTargetCompatible(unit) else { return }
        targetUnit = unit
        applyDefaultOutputDisplayMode()
        performConversion()
    }

    func applyCalculatorResult(value: String, category: ConversionCategory, unit: ConversionUnit) {
        self.category = category
        sourceUnit = unit
        inputText = value
        inputDisplayMode = value.contains("/") ? .fraction : .decimal
        inputError = nil
        outputDisplayModeOverridden = false
        reconcileTargetUnit()
        applyDefaultOutputDisplayMode()
        performConversion()
    }

    func setInputText(_ text: String) {
        inputText = text
        performConversion()
    }

    func performConversion() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else {
            result = nil
            inputError = nil
            return
        }

        switch ConversionEngine.convert(input: inputText, from: sourceUnit, to: targetUnit, category: category) {
        case .success(let conversionResult):
            result = formattedResult(from: conversionResult.numericValue)
            inputError = nil
        case .failure(.invalidInput):
            result = nil
            inputError = "Enter a number or fraction like 3 3/32."
        case .failure(.incompatibleUnits):
            result = nil
            inputError = "These units can't be converted together."
        case .failure(.outOfRange):
            result = nil
            inputError = "Value is out of range."
        }
    }

    private var parsedInputValue: Double? {
        switch ConversionEngine.parseNumericInput(inputText, from: sourceUnit, category: category) {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    private func formattedResult(from numericValue: Double) -> ConversionResult {
        let primary = ConversionFormatting.formatResult(
            value: numericValue,
            unit: targetUnit,
            category: category,
            displayMode: outputDisplayMode
        )
        let copyable = ConversionFormatting.copyableOutput(
            value: numericValue,
            unit: targetUnit,
            category: category,
            displayMode: outputDisplayMode
        )
        return ConversionResult(
            numericValue: numericValue,
            formattedValue: primary,
            secondaryFormattedValue: nil,
            copyableOutput: copyable
        )
    }

    private func reconcileUnitsAfterCategoryChange() {
        let units = availableUnits
        if !units.contains(sourceUnit) {
            sourceUnit = units.first ?? .inches
        }
        outputDisplayModeOverridden = false
        reconcileTargetUnit()
        applyDefaultOutputDisplayMode()
        performConversion()
    }

    private func reconcileTargetUnit() {
        let compatible = ConversionUnitCompatibility.compatibleTargets(
            from: sourceUnit,
            in: category,
            available: availableUnits
        )
        if !isTargetCompatible(targetUnit) {
            targetUnit = compatible.first ?? availableUnits.first(where: { $0 != sourceUnit }) ?? targetUnit
        }
    }

    private func applyDefaultOutputDisplayMode() {
        guard !outputDisplayModeOverridden else { return }
        outputDisplayMode = ConversionFormatting.defaultDisplayMode(
            for: targetUnit,
            category: category
        )
    }
}
