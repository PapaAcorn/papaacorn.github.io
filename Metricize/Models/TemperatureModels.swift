//
//  TemperatureModels.swift
//  Metricize
//

import Foundation

enum ChallengeType: String, Codable, CaseIterable {
    case thermometerSlider
    case multipleChoice
}

struct TemperatureCard: Identifiable, Codable, Equatable {
    let id: String
    let celsius: Int
    let roundIndex: Int
    let challengeType: ChallengeType
    let label: String?

    var correctFahrenheit: Int {
        TemperatureConversion.fahrenheit(fromCelsius: celsius)
    }

    init(celsius: Int, roundIndex: Int, challengeType: ChallengeType, label: String? = nil) {
        self.id = "c\(celsius)-r\(roundIndex)"
        self.celsius = celsius
        self.roundIndex = roundIndex
        self.challengeType = challengeType
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
}

enum TemperatureGameConstants {
    static let requiredConsecutiveCorrect = 3
    static let sliderToleranceFahrenheit = 2
    static let multipleChoiceToleranceFahrenheit = 2
    static let fahrenheitMin = -15
    static let fahrenheitMax = 110
    static let reviewCardWeight = 1
    static let currentRoundCardWeight = 10
    static let strugglingCardWeight = 18
    static let partialProgressWeight = 8
}

enum TemperatureConversion {
    static func fahrenheit(fromCelsius celsius: Int) -> Int {
        Int((Double(celsius) * 9.0 / 5.0 + 32).rounded())
    }

    static func celsius(fromFahrenheit fahrenheit: Int) -> Int {
        Int(((Double(fahrenheit) - 32) * 5.0 / 9.0).rounded())
    }

    static func isWithinTolerance(guess: Int, target: Int, tolerance: Int) -> Bool {
        abs(guess - target) <= tolerance
    }
}
