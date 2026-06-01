import Foundation

struct ConversionRegressionCase {
    let category: String
    let inputValue: Double
    let inputUnit: String
    let outputUnit: String
    let expectedResult: Double
    let tolerance: Double
    let notes: String
}

enum CalculatorRegressionCases {
    static let supportedCategories = ["Temperature"]

    static let unsupportedCategories = [
        "Distance / Length",
        "Weight / Mass",
        "Volume",
        "Speed",
        "Construction fractions",
        "Kitchen formatting",
        "Free-form input parsing",
    ]

    static let temperature: [ConversionRegressionCase] = [
        ConversionRegressionCase(
            category: "Temperature",
            inputValue: 0,
            inputUnit: "°C",
            outputUnit: "°F",
            expectedResult: 32,
            tolerance: 2,
            notes: "Freezing water anchor"
        ),
        ConversionRegressionCase(
            category: "Temperature",
            inputValue: 10,
            inputUnit: "°C",
            outputUnit: "°F",
            expectedResult: 50,
            tolerance: 2,
            notes: "Cool jacket weather"
        ),
        ConversionRegressionCase(
            category: "Temperature",
            inputValue: 38,
            inputUnit: "°C",
            outputUnit: "°F",
            expectedResult: 100,
            tolerance: 2,
            notes: "Very hot outside"
        ),
        ConversionRegressionCase(
            category: "Temperature",
            inputValue: -15,
            inputUnit: "°F",
            outputUnit: "°C",
            expectedResult: -26,
            tolerance: 2,
            notes: "Lower supported environmental endpoint"
        ),
        ConversionRegressionCase(
            category: "Temperature",
            inputValue: 110,
            inputUnit: "°F",
            outputUnit: "°C",
            expectedResult: 43,
            tolerance: 2,
            notes: "Upper supported environmental endpoint"
        ),
        ConversionRegressionCase(
            category: "Temperature",
            inputValue: 68,
            inputUnit: "°F",
            outputUnit: "°C",
            expectedResult: 20,
            tolerance: 2,
            notes: "Comfortable room"
        ),
        ConversionRegressionCase(
            category: "Temperature",
            inputValue: 70,
            inputUnit: "°F",
            outputUnit: "°C",
            expectedResult: 21,
            tolerance: 2,
            notes: "Pleasant outside"
        ),
    ]
}
