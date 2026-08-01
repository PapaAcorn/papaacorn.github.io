//
//  TemperatureFormatting.swift
//  Metricize
//

import Foundation

enum TemperatureFormatting {
    static func symbol(celsius: Int) -> String {
        "\(celsius)°C"
    }

    static func symbol(fahrenheit: Int) -> String {
        "\(fahrenheit)°F"
    }

    static func degreesPhrase(value: Int, unit: String) -> String {
        switch unit {
        case "°F", "F": "\(value) degrees Fahrenheit"
        case "°C", "C": "\(value) degrees Celsius"
        default: "\(value)\(unit)"
        }
    }

    /// Prevents line breaks splitting decimal numbers like 98.6 across lines.
    static func preventDecimalLineBreaks(_ text: String) -> String {
        text.replacingOccurrences(
            of: #"(\d)\.(\d)"#,
            with: "$1.\u{2060}$2",
            options: .regularExpression
        )
    }
}

extension String {
    var withDecimalLineBreakProtection: String {
        TemperatureFormatting.preventDecimalLineBreaks(self)
    }
}
