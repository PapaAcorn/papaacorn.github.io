//
//  CalculatorSendPreferences.swift
//  Metricize
//

import Foundation

enum CalculatorSendPreferences {
    private static let suppressWarningKey = "metricize.calculator.suppressSendWarning"

    static var suppressSendWarning: Bool {
        get { UserDefaults.standard.bool(forKey: suppressWarningKey) }
        set { UserDefaults.standard.set(newValue, forKey: suppressWarningKey) }
    }
}
