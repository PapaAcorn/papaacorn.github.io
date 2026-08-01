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

enum TemperatureRoundKind: Equatable {
    case learning
    case finalExam
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
        if roundIndex == TemperatureGameConstants.finalExamRoundIndex {
            switch direction {
            case .celsiusToFahrenheit:
                return TemperatureGameConstants.examFahrenheitRange
            case .fahrenheitToCelsius:
                return TemperatureGameConstants.examCelsiusRange
            }
        }
        switch direction {
        case .celsiusToFahrenheit:
            return TemperatureGameConstants.fahrenheitMin...TemperatureGameConstants.fahrenheitMax
        case .fahrenheitToCelsius:
            return TemperatureGameConstants.celsiusMin...TemperatureGameConstants.celsiusMax
        }
    }

    init(
        celsius: Int,
        roundIndex: Int,
        challengeType: ChallengeType,
        direction: ConversionDirection,
        label: String? = nil,
        examQuestionID: String? = nil
    ) {
        if let examQuestionID {
            self.id = examQuestionID
        } else {
            self.id = "c\(celsius)-r\(roundIndex)-\(direction.rawValue)"
        }
        self.celsius = celsius
        self.roundIndex = roundIndex
        self.challengeType = challengeType
        self.direction = direction
        self.label = label
    }
}

struct CardProgress: Codable, Equatable {
    var consecutiveCorrect: Int = 0
    var mixedConsecutiveCorrect: Int = 0
    var totalCorrect: Int = 0
    var totalIncorrect: Int = 0

    var isLearned: Bool {
        consecutiveCorrect >= LearningPreferences.requiredConsecutiveCorrect
    }

    var isMixedLearned: Bool {
        mixedConsecutiveCorrect >= LearningPreferences.requiredConsecutiveCorrect
    }
}

struct TemperatureRound: Identifiable {
    let index: Int
    let title: String
    let kind: TemperatureRoundKind
    let cards: [TemperatureCard]

    var id: Int { index }

    var isFinalExam: Bool { kind == .finalExam }

    var subRoundCount: Int {
        isFinalExam ? 1 : TemperatureGameConstants.subRoundsPerRound
    }

    /// Five anchor conversions per learning round (each appears in both directions).
    var anchorCount: Int {
        cards.filter { $0.direction == .celsiusToFahrenheit }.count
    }
}

struct FinalExamSession: Codable, Equatable {
    var questions: [TemperatureCard]
    var currentQuestionIndex: Int = 0
    var correctCount: Int = 0

    var totalQuestions: Int { questions.count }

    var isComplete: Bool {
        currentQuestionIndex >= questions.count
    }

    var scoreFraction: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctCount) / Double(totalQuestions)
    }
}

enum TemperatureGameConstants {
    static let subRoundsPerRound = 3
    static let mixedSubRoundIndex = 2
    static let finalExamRoundIndex = 3
    static let learningRoundCount = 3
    static let examFahrenheitMin = -10
    static let examFahrenheitMax = 105
    static let examQuestionCount = 20
    static let examPassFraction = 0.8
    static let examPassCorrectCount = Int(ceil(Double(examQuestionCount) * examPassFraction))
    static var examCelsiusRange: ClosedRange<Int> {
        TemperatureConversion.celsius(fromFahrenheit: examFahrenheitMin)...TemperatureConversion.celsius(fromFahrenheit: examFahrenheitMax)
    }

    static var examFahrenheitRange: ClosedRange<Int> {
        examFahrenheitMin...examFahrenheitMax
    }

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

    static func isWithinTolerance(guess: Int, target: Int, tolerance: Int) -> Bool {
        abs(guess - target) <= tolerance
    }

    enum AnswerResult {
        case exact
        case closeEnough
        case incorrect
    }

    static func evaluate(guess: Int, target: Int, tolerance: Int) -> AnswerResult {
        if isExact(guess: guess, target: target) { return .exact }
        if isWithinTolerance(guess: guess, target: target, tolerance: tolerance) { return .closeEnough }
        return .incorrect
    }

    static func neutralSliderDefault(for card: TemperatureCard) -> Double {
        let range = card.answerRange
        let correct = card.correctAnswer
        let candidates: [Int]
        switch card.direction {
        case .celsiusToFahrenheit:
            candidates = [50, 68, 32, 86, 14, 0, -4].filter { range.contains($0) && $0 != correct }
        case .fahrenheitToCelsius:
            candidates = [10, 0, 20, -5, 15, -10].filter { range.contains($0) && $0 != correct }
        }
        if let pick = candidates.first {
            return Double(pick)
        }
        let midpoint = (range.lowerBound + range.upperBound) / 2
        return Double(midpoint == correct ? midpoint + 5 : midpoint)
    }
}
