//
//  KitchenModels.swift
//  Metricize
//

import Foundation

enum KitchenCardKind: String, Codable, CaseIterable {
    case volume
    case weight
    case ovenTemperature
    case foodSafetyTemperature
    case booleanComparison
    case panSize
    case panConcept
}

enum KitchenConversionDirection: String, Codable, CaseIterable {
    case imperialToMetric
    case metricToImperial
}

enum KitchenChallengeType: String, Codable, CaseIterable {
    case measurementSlider
    case multipleChoice
    case booleanChoice
}

enum KitchenRoundKind: Equatable {
    case learning
    case finalExam
}

struct KitchenCard: Identifiable, Codable, Equatable {
    let id: String
    let roundIndex: Int
    let kind: KitchenCardKind
    let direction: KitchenConversionDirection
    let challengeType: KitchenChallengeType
    let prompt: String
    let promptValue: Int?
    let promptUnit: String?
    let correctAnswer: Int
    let answerUnit: String
    let label: String?
    /// Food-safety temperatures must match exactly — no tolerance and no dangerously low guesses.
    let requiresExactAnswer: Bool
    let alternateExactAnswer: Int?
    let toleranceOverride: Int?
    /// Human-readable correct answer for pan-size and concept cards.
    let answerLabel: String?
    /// When set, multiple-choice options use these labels and `correctAnswer` is the index.
    let choiceLabels: [String]?

    var usesLabeledChoices: Bool {
        choiceLabels != nil || answerLabel != nil
    }

    var usesTemperatureSlider: Bool {
        kind == .ovenTemperature || kind == .foodSafetyTemperature
    }

    var promptDisplayValue: Int {
        promptValue ?? correctAnswer
    }

    var answerRange: ClosedRange<Int> {
        if roundIndex == KitchenGameConstants.finalExamRoundIndex {
            return KitchenConversion.answerRange(for: kind, direction: direction, isExam: true)
        }
        return KitchenConversion.answerRange(for: kind, direction: direction, isExam: false)
    }

    var hint: String {
        switch challengeType {
        case .booleanChoice:
            return "Choose yes or no"
        case .measurementSlider where usesTemperatureSlider:
            switch direction {
            case .imperialToMetric:
                return "Drag the marker on the Celsius scale"
            case .metricToImperial:
                return "Drag the marker on the Fahrenheit scale"
            }
        case .measurementSlider:
            return "Drag the marker to your best estimate"
        case .multipleChoice:
            if kind == .foodSafetyTemperature {
                return "Choose the USDA minimum internal temperature"
            }
            if kind == .panSize {
                return "Which is the closest common equivalent? (Not an exact conversion.)"
            }
            if kind == .panConcept {
                return "Choose the best answer"
            }
            return "is about how many\(answerUnit.hasPrefix(" ") ? answerUnit : " \(answerUnit)")?"
        }
    }

    init(
        roundIndex: Int,
        kind: KitchenCardKind,
        direction: KitchenConversionDirection,
        challengeType: KitchenChallengeType,
        prompt: String,
        promptValue: Int? = nil,
        promptUnit: String? = nil,
        correctAnswer: Int,
        answerUnit: String,
        label: String? = nil,
        requiresExactAnswer: Bool = false,
        alternateExactAnswer: Int? = nil,
        toleranceOverride: Int? = nil,
        answerLabel: String? = nil,
        choiceLabels: [String]? = nil,
        examQuestionID: String? = nil
    ) {
        if let examQuestionID {
            self.id = examQuestionID
        } else {
            self.id = "k-r\(roundIndex)-\(direction.rawValue)-\(Self.stableIDComponent(from: prompt))"
        }
        self.roundIndex = roundIndex
        self.kind = kind
        self.direction = direction
        self.challengeType = challengeType
        self.prompt = prompt
        self.promptValue = promptValue
        self.promptUnit = promptUnit
        self.correctAnswer = correctAnswer
        self.answerUnit = answerUnit
        self.label = label
        self.requiresExactAnswer = requiresExactAnswer
        self.alternateExactAnswer = alternateExactAnswer
        self.toleranceOverride = toleranceOverride
        self.answerLabel = answerLabel
        self.choiceLabels = choiceLabels
    }

    private static func stableIDComponent(from prompt: String) -> String {
        prompt
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "/", with: "-")
    }
}

struct KitchenRound: Identifiable {
    let index: Int
    let title: String
    let kind: KitchenRoundKind
    let cards: [KitchenCard]

    var id: Int { index }

    var isFinalExam: Bool { kind == .finalExam }

    var subRoundCount: Int {
        isFinalExam ? 1 : KitchenGameConstants.subRoundsPerRound
    }

    var anchorCount: Int {
        cards.filter {
            $0.direction == .imperialToMetric
                && $0.kind != .booleanComparison
                && $0.kind != .panConcept
        }.count
    }
}

struct KitchenFinalExamSession: Codable, Equatable {
    var questions: [KitchenCard]
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

enum KitchenGameConstants {
    static let subRoundsPerRound = 3
    static let mixedSubRoundIndex = 2
    static let learningRoundCount = 5
    static let finalExamRoundIndex = 5
    static let examQuestionCount = 20
    static let examPassFraction = 0.8
    static let examPassCorrectCount = Int(ceil(Double(examQuestionCount) * examPassFraction))

    static let reviewCardWeight = 1
    static let currentRoundCardWeight = 10
    static let strugglingCardWeight = 18
    static let partialProgressWeight = 8

    static let defaultSliderMilliliters = 120.0
    static let defaultSliderGrams = 120.0
    static let defaultSliderCount = 1.0
    static let learningBatchSize = 5
}

typealias KitchenBatchReviewItem = ConversionReviewItem

enum KitchenConversion {
    enum AnswerResult {
        case exact
        case closeEnough
        case incorrect
    }

    static func fahrenheit(fromCelsius celsius: Int) -> Int {
        TemperatureConversion.fahrenheit(fromCelsius: celsius)
    }

    static func celsius(fromFahrenheit fahrenheit: Int) -> Int {
        TemperatureConversion.celsius(fromFahrenheit: fahrenheit)
    }

    static func effectiveTolerance(for card: KitchenCard) -> Int {
        if card.requiresExactAnswer { return 0 }
        // Kitchen conversions require exact taught anchors — especially food safety.
        return 0
    }

    static func evaluate(guess: Int, for card: KitchenCard, tolerance: Int) -> AnswerResult {
        if card.kind == .booleanComparison || card.kind == .panConcept {
            return guess == card.correctAnswer ? .exact : .incorrect
        }

        if card.kind == .panSize || card.answerLabel != nil {
            return guess == card.correctAnswer ? .exact : .incorrect
        }

        if card.requiresExactAnswer {
            if guess == card.correctAnswer { return .exact }
            if let alternate = card.alternateExactAnswer, guess == alternate { return .exact }
            return .incorrect
        }

        let target = card.correctAnswer
        if guess == target { return .exact }
        if abs(guess - target) <= tolerance { return .closeEnough }
        return .incorrect
    }

    /// Plausible wrong answers drawn from taught kitchen anchors — keeps choices spread apart.
    static func distractorCandidates(for card: KitchenCard) -> [Int] {
        switch card.kind {
        case .volume:
            if card.answerUnit.contains("mL") {
                return [1, 2, 5, 10, 15, 30, 60, 80, 120, 180, 240, 480, 500, 1000]
            }
            return [1, 2, 3, 4, 8]
        case .weight:
            return [14, 28, 30, 113, 120, 190, 200, 220, 450, 500]
        case .ovenTemperature:
            if card.answerUnit == "°C" {
                return [150, 160, 175, 190, 200, 220, 230]
            }
            return [300, 325, 350, 375, 400, 425, 450]
        case .foodSafetyTemperature:
            return [145, 160, 165, 63, 71, 74, 180]
        case .booleanComparison, .panConcept:
            return [0, 1]
        case .panSize:
            return []
        }
    }

    static func minimumDistractorSeparation(for card: KitchenCard) -> Int {
        switch card.kind {
        case .volume where card.answerUnit.contains("mL"):
            return 10
        case .weight:
            return 20
        case .ovenTemperature, .foodSafetyTemperature:
            return 5
        default:
            return 1
        }
    }

    static func answerRange(for kind: KitchenCardKind, direction: KitchenConversionDirection, isExam: Bool) -> ClosedRange<Int> {
        switch kind {
        case .ovenTemperature, .foodSafetyTemperature:
            switch direction {
            case .imperialToMetric:
                return isExam
                    ? TemperatureGameConstants.examCelsiusRange
                    : TemperatureGameConstants.celsiusMin...TemperatureGameConstants.celsiusMax
            case .metricToImperial:
                return isExam
                    ? TemperatureGameConstants.examFahrenheitRange
                    : TemperatureGameConstants.fahrenheitMin...TemperatureGameConstants.fahrenheitMax
            }
        case .volume:
            return isExam ? 1...1000 : 1...1000
        case .weight:
            return isExam ? 1...500 : 1...500
        case .booleanComparison, .panConcept:
            return 0...1
        case .panSize:
            return 0...3
        }
    }

    static let metricPanSizeLabels: [String] = [
        "18 × 18 cm",
        "20 × 20 cm",
        "20 × 30 cm",
        "20 cm round",
        "23 × 13 cm",
        "23 × 23 cm",
        "23 × 33 cm",
        "23 cm round",
        "23 cm pie dish",
        "25 cm round",
        "28 × 18 cm",
        "12-hole muffin tin",
        "21.5 × 11.5 cm",
    ]

    static let imperialPanSizeLabels: [String] = [
        "7 × 7 inch square pan",
        "8 × 8 inch square pan",
        "8 × 12 inch baking dish",
        "8 inch round cake pan",
        "8.5 × 4.5 inch loaf pan",
        "9 × 5 inch loaf pan",
        "9 × 9 inch square pan",
        "9 × 13 inch baking dish",
        "9 inch pie dish",
        "9 inch round cake pan",
        "10 inch round cake pan",
        "11 × 7 inch baking dish",
        "12-cup muffin tin",
    ]

        static func panSizeDistractorLabels(for card: KitchenCard) -> [String] {
        switch card.direction {
        case .imperialToMetric:
            return metricPanSizeLabels
        case .metricToImperial:
            return imperialPanSizeLabels
        }
    }

    static func neutralSliderDefault(for card: KitchenCard) -> Double {
        switch card.answerUnit {
        case " mL":
            return KitchenGameConstants.defaultSliderMilliliters
        case " g":
            return KitchenGameConstants.defaultSliderGrams
        case "°C":
            return neutralTemperatureDefault(
                candidates: [10, 0, 20, -5, 15, -10],
                correct: card.correctAnswer,
                range: card.answerRange,
                fallback: TemperatureGameConstants.defaultSliderCelsius
            )
        case "°F":
            return neutralTemperatureDefault(
                candidates: [50, 68, 32, 86, 14, 0, -4],
                correct: card.correctAnswer,
                range: card.answerRange,
                fallback: TemperatureGameConstants.defaultSliderFahrenheit
            )
        default:
            break
        }

        let range = card.answerRange
        let correct = card.correctAnswer
        let span = range.upperBound - range.lowerBound
        let offsets = [span / 4, span / 2, 3 * span / 4, max(1, span / 6)]
        for offset in offsets {
            let candidate = range.lowerBound + offset
            if candidate != correct, range.contains(candidate) {
                return Double(candidate)
            }
        }
        if correct > range.lowerBound {
            return Double(correct - 1)
        }
        return Double(min(correct + 1, range.upperBound))
    }

    private static func neutralTemperatureDefault(
        candidates: [Int],
        correct: Int,
        range: ClosedRange<Int>,
        fallback: Double
    ) -> Double {
        for candidate in candidates where range.contains(candidate) && candidate != correct {
            return Double(candidate)
        }
        return fallback
    }
}

enum KitchenFormatting {
    static func answerPhrase(value: Int, unit: String) -> String {
        switch unit {
        case "°F", "F":
            return TemperatureFormatting.degreesPhrase(value: value, unit: "°F")
        case "°C", "C":
            return TemperatureFormatting.degreesPhrase(value: value, unit: "°C")
        case " mL", "mL":
            return "\(value) milliliters"
        case " g", "g":
            return "\(value) grams"
        case " cup", " cups":
            return value == 1 ? "1 cup" : "\(value) cups"
        case " tbsp":
            return value == 1 ? "1 tablespoon" : "\(value) tablespoons"
        case " tsp":
            return value == 1 ? "1 teaspoon" : "\(value) teaspoons"
        case " lb", " lbs":
            return value == 1 ? "1 pound" : "\(value) pounds"
        case " oz":
            return value == 1 ? "1 ounce" : "\(value) ounces"
        case " quart", " quarts":
            return value == 1 ? "1 quart" : "\(value) quarts"
        case " pint", " pints":
            return value == 1 ? "1 pint" : "\(value) pints"
        case " fl oz":
            return value == 1 ? "1 fluid ounce" : "\(value) fluid ounces"
        default:
            return "\(value)\(unit)"
        }
    }

    static func booleanPhrase(isYes: Bool) -> String {
        isYes ? "Yes" : "No"
    }

    static func displayAnswer(for card: KitchenCard, value: Int) -> String {
        if card.kind == .booleanComparison || card.kind == .panConcept,
           let labels = card.choiceLabels,
           labels.indices.contains(value) {
            return labels[value]
        }
        if let answerLabel = card.answerLabel {
            return answerLabel
        }
        return answerPhrase(value: value, unit: card.answerUnit)
    }
}
