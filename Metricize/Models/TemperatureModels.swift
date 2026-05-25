//
//  TemperatureModels.swift
//  Metricize
//

import Foundation

enum ChallengeType: String, Codable, CaseIterable {
    case thermometerSlider
    case multipleChoice
}

enum ConversionDirection: String, Codable, CaseIterable {
    case celsiusToFahrenheit
    case fahrenheitToCelsius
}

struct TemperatureCard: Identifiable, Codable, Equatable {
    let id: String
    let celsius: Int
    let roundIndex: Int
    let challengeType: ChallengeType
    let direction: ConversionDirection
    let label: String?

    var correctFahrenheit: Int {
        TemperatureConversion.fahrenheit(fromCelsius: celsius)
    }

    var correctAnswer: Int {
        switch direction {
        case .celsiusToFahrenheit: correctFahrenheit
        case .fahrenheitToCelsius: celsius
        }
    }

    var promptValue: Int {
        switch direction {
        case .celsiusToFahrenheit: celsius
        case .fahrenheitToCelsius: correctFahrenheit
        }
    }

    var promptUnit: String {
        switch direction {
        case .celsiusToFahrenheit: "°C"
        case .fahrenheitToCelsius: "°F"
        }
    }

    var answerUnit: String {
        switch direction {
        case .celsiusToFahrenheit: "°F"
        case .fahrenheitToCelsius: "°C"
        }
    }

    var answerRange: ClosedRange<Int> {
        switch direction {
        case .celsiusToFahrenheit:
            TemperatureGameConstants.fahrenheitMin...TemperatureGameConstants.fahrenheitMax
        case .fahrenheitToCelsius:
            TemperatureGameConstants.celsiusMin...TemperatureGameConstants.celsiusMax
        }
    }

    init(
        celsius: Int,
        roundIndex: Int,
        challengeType: ChallengeType,
        direction: ConversionDirection,
        label: String? = nil
    ) {
        self.id = "c\(celsius)-r\(roundIndex)-\(direction.rawValue)"
        self.celsius = celsius
        self.roundIndex = roundIndex
        self.challengeType = challengeType
        self.direction = direction
        self.label = label
    }
}

struct CardProgress: Codable, Equatable {
    var consecutiveCorrect: Int = 0
    var totalCorrect: Int = 0
    var totalIncorrect: Int = 0

    var isLearned: Bool {
        consecutiveCorrect >= TemperatureGameConstants.requiredConsecutiveCorrect
    }
}

struct TemperatureRound: Identifiable {
    let index: Int
    let title: String
    let cards: [TemperatureCard]

    var id: Int { index }

    /// Five anchor conversions per round (each appears in both directions).
    var anchorCount: Int {
        cards.filter { $0.direction == .celsiusToFahrenheit }.count
    }
}

enum TemperatureGameConstants {
    static let requiredConsecutiveCorrect = 3
    static let toleranceDegrees = 3
    static let fahrenheitMin = -10
    static let fahrenheitMax = 110
    static let celsiusMin = -23
    static let celsiusMax = 43
    static let reviewCardWeight = 1
    static let currentRoundCardWeight = 10
    static let strugglingCardWeight = 18
    static let partialProgressWeight = 8
    static let defaultSliderFahrenheit = 50.0
    static let defaultSliderCelsius = 10.0
}

enum TemperatureConversion {
    static func fahrenheit(fromCelsius celsius: Int) -> Int {
        Int((Double(celsius) * 9.0 / 5.0 + 32).rounded())
    }

    static func celsius(fromFahrenheit fahrenheit: Int) -> Int {
        Int(((Double(fahrenheit) - 32) * 5.0 / 9.0).rounded())
    }

    static func isExact(guess: Int, target: Int) -> Bool {
        guess == target
    }

    static func isWithinTolerance(guess: Int, target: Int, tolerance: Int = TemperatureGameConstants.toleranceDegrees) -> Bool {
        abs(guess - target) <= tolerance
    }

    enum AnswerResult {
        case exact
        case closeEnough
        case incorrect
    }

    static func evaluate(guess: Int, target: Int) -> AnswerResult {
        if isExact(guess: guess, target: target) { return .exact }
        if isWithinTolerance(guess: guess, target: target) { return .closeEnough }
        return .incorrect
    }
}
