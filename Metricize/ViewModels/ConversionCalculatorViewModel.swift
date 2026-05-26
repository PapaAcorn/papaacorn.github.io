//
//  ConversionCalculatorViewModel.swift
//  Metricize
//

import Foundation
import Observation

@Observable
final class ConversionCalculatorViewModel {
    var category: ConversionCategory = .distance {
        didSet { reconcileUnitsAfterCategoryChange() }
    }

    var sourceUnit: ConversionUnit = .inches
    var targetUnit: ConversionUnit = .millimeters
    var inputText: String = ""
    var result: ConversionResult?
    var inputError: String?
    var isLandscape: Bool = false
    var hasShownLandscapeHint: Bool {
        get { UserDefaults.standard.bool(forKey: Self.landscapeHintKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.landscapeHintKey) }
    }

    private static let landscapeHintKey = "metricize.conversion.landscapeHintShown"

    var availableUnits: [ConversionUnit] {
        ConversionUnit.units(for: category, landscape: isLandscape)
    }

    var showsLandscapeHint: Bool {
        category.hasLandscapeExtras && !isLandscape && !hasShownLandscapeHint
    }

    var showsKitchenCompatibility: Bool {
        category == .kitchen
    }

    var supportsMixedLengthInput: Bool {
        category == .distance || category == .construction
    }

    var inputPlaceholder: String {
        if supportsMixedLengthInput {
            return "5 ft 10 in or 5, 10"
        }
        if sourceUnit.acceptsFractions || category == .construction {
            return "Enter value or fraction"
        }
        return "Enter a value"
    }

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

    func updateLandscape(_ landscape: Bool) {
        isLandscape = landscape
        if landscape, category.hasLandscapeExtras {
            hasShownLandscapeHint = true
        }
    }

    func dismissLandscapeHint() {
        hasShownLandscapeHint = true
    }

    func appendInput(_ token: String) {
        inputError = nil
        if token == "/" {
            if inputText.contains("/") { return }
            if inputText.isEmpty { inputText = "0" }
            inputText += "/"
        } else if token == " " {
            if inputText.isEmpty || inputText.hasSuffix(" ") { return }
            inputText += " "
        } else if token == "," {
            guard supportsMixedLengthInput else { return }
            if inputText.contains(",") { return }
            if inputText.isEmpty { return }
            inputText += ","
        } else if token == "." {
            let lastSegment = inputText.split(separator: " ").last.map(String.init) ?? inputText
            guard !lastSegment.contains(".") else { return }
            if inputText.isEmpty { inputText = "0" }
            inputText += "."
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
            inputText = ConversionFormatting.format(value: currentResult.numericValue, unit: sourceUnit, isInput: true)
        }
        reconcileTargetUnit()
        performConversion()
    }

    func selectCategory(_ newCategory: ConversionCategory) {
        category = newCategory
    }

    func selectSourceUnit(_ unit: ConversionUnit) {
        sourceUnit = unit
        reconcileTargetUnit()
        performConversion()
    }

    func selectTargetUnit(_ unit: ConversionUnit) {
        guard isTargetCompatible(unit) else { return }
        targetUnit = unit
        performConversion()
    }

    func applyVoiceRequest(_ request: VoiceConversionRequest) {
        category = request.category
        sourceUnit = request.sourceUnit
        targetUnit = request.targetUnit
        inputText = request.inputText
        inputError = request.confidence < 0.6 ? "Check the interpreted values below." : nil
        reconcileTargetUnit()
        performConversion()
    }

    func applyCalculatorResult(value: String, category: ConversionCategory, unit: ConversionUnit) {
        self.category = category
        sourceUnit = unit
        inputText = value
        inputError = nil
        reconcileTargetUnit()
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
            result = conversionResult
            inputError = nil
        case .failure(.invalidInput):
            result = nil
            inputError = supportsMixedLengthInput
                ? "Enter a number, fraction, or mixed length like 5 ft 10 in."
                : "Enter a number or fraction like 3 3/32."
        case .failure(.incompatibleUnits):
            result = nil
            inputError = "These units can't be converted together."
        case .failure(.outOfRange):
            result = nil
            inputError = "Value is out of range."
        }
    }

    private func reconcileUnitsAfterCategoryChange() {
        let units = availableUnits
        if !units.contains(sourceUnit) {
            sourceUnit = units.first ?? .inches
        }
        reconcileTargetUnit()
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
}
