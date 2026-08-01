//
//  ShopModels.swift
//  Metricize
//

import Foundation

enum ShopCardKind: String, Codable, CaseIterable {
    case smallPackageWeight
    case largerGroceryWeight
    case bottleLiquid
    case clothingMeasurement
    case productDimension
}

enum ShopConversionDirection: String, Codable, CaseIterable {
    case metricToImperial
    case imperialToMetric
}

enum ShopChallengeType: String, Codable, CaseIterable {
    case multipleChoice
}

enum ShopRoundKind: Equatable {
    case learning
    case finalExam
}

struct ShopCard: Identifiable, Codable, Equatable {
    let id: String
    let roundIndex: Int
    let kind: ShopCardKind
    let direction: ShopConversionDirection
    let challengeType: ShopChallengeType
    let prompt: String
    let promptValue: Int?
    let promptUnit: String?
    let correctAnswer: Int
    let answerUnit: String
    let label: String?
    let answerLabel: String

    var usesLabeledChoices: Bool { true }

    var promptDisplayValue: Int {
        promptValue ?? correctAnswer
    }

    var hint: String {
        "Choose the closest practical shopping approximation."
    }

    init(
        roundIndex: Int,
        kind: ShopCardKind,
        direction: ShopConversionDirection,
        challengeType: ShopChallengeType = .multipleChoice,
        prompt: String,
        promptValue: Int? = nil,
        promptUnit: String? = nil,
        correctAnswer: Int = 0,
        answerUnit: String = "",
        label: String? = nil,
        answerLabel: String,
        examQuestionID: String? = nil
    ) {
        if let examQuestionID {
            self.id = examQuestionID
        } else {
            self.id = "shop-r\(roundIndex)-\(direction.rawValue)-\(Self.stableIDComponent(from: prompt))"
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
        self.answerLabel = answerLabel
    }

    private static func stableIDComponent(from prompt: String) -> String {
        prompt
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "—", with: "-")
            .replacingOccurrences(of: "≈", with: "")
    }
}

struct ShopRound: Identifiable {
    let index: Int
    let title: String
    let kind: ShopRoundKind
    let cards: [ShopCard]

    var id: Int { index }

    var isFinalExam: Bool { kind == .finalExam }

    var subRoundCount: Int {
        isFinalExam ? 1 : ShopGameConstants.subRoundsPerRound
    }

    var anchorCount: Int {
        cards.filter { $0.direction == .metricToImperial }.count
    }
}

struct ShopFinalExamSession: Codable, Equatable {
    var questions: [ShopCard]
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

enum ShopGameConstants {
    static let subRoundsPerRound = 3
    static let mixedSubRoundIndex = 2
    static let learningRoundCount = 5
    static let finalExamRoundIndex = 5
    static let examQuestionCount = 25
    static let examPassFraction = 0.8
    static let examPassCorrectCount = Int(ceil(Double(examQuestionCount) * examPassFraction))
    static let examQuestionsPerRound = 5

    static let reviewCardWeight = 1
    static let currentRoundCardWeight = 10
    static let strugglingCardWeight = 18
    static let partialProgressWeight = 8

    static let learningBatchSize = 5
}

enum ShopConversion {
    enum AnswerResult {
        case exact
        case incorrect
    }

    static func evaluate(guess: Int, correctIndex: Int) -> AnswerResult {
        guess == correctIndex ? .exact : .incorrect
    }

    static func distractorLabels(for card: ShopCard) -> [String] {
        switch card.kind {
        case .smallPackageWeight:
            if card.direction == .metricToImperial {
                return [
                    "1 oz", "2 oz", "2.5 oz", "3.5 oz", "4 oz", "5 oz", "7 oz", "9 oz",
                    "10 oz", "14 oz", "1 lb", "1.1 lb",
                ]
            }
            return [
                "25 g", "50 g", "75 g", "100 g", "125 g", "150 g", "200 g", "250 g",
                "300 g", "400 g", "450 g", "500 g",
            ]
        case .largerGroceryWeight:
            if card.direction == .metricToImperial {
                return [
                    "1.1 lb", "1.5 lb", "2.2 lb", "3.3 lb", "4.4 lb", "5.5 lb", "6.5 lb",
                    "9 lb", "11 lb", "16.5 lb", "22 lb", "44 lb",
                ]
            }
            return [
                "0.5 kg", "0.75 kg", "1 kg", "1.5 kg", "2 kg", "2.5 kg", "3 kg",
                "4 kg", "5 kg", "7.5 kg", "10 kg", "20 kg",
            ]
        case .bottleLiquid:
            if card.direction == .metricToImperial {
                return [
                    "3.5 fl oz", "5 fl oz", "7 fl oz", "1 cup / 8 fl oz", "11 fl oz",
                    "1 pint / 17 fl oz", "25 fl oz", "1 quart", "1.5 quarts", "2 quarts",
                    "3 quarts", "1 gallon", "1.3 gallons",
                ]
            }
            return [
                "100 mL", "150 mL", "200 mL", "250 mL", "330 mL", "500 mL", "750 mL",
                "1 L", "1.5 L", "2 L", "3 L", "4 L", "5 L",
            ]
        case .clothingMeasurement:
            if card.direction == .metricToImperial {
                return [
                    "12 inches", "16 inches", "20 inches", "24 inches", "28 inches", "30 inches",
                    "32 inches", "34 inches", "36 inches", "38 inches", "40 inches", "42 inches",
                    "44 inches", "46 inches", "48 inches",
                ]
            }
            return [
                "30 cm", "40 cm", "50 cm", "60 cm", "70 cm", "75 cm", "80 cm", "85 cm",
                "90 cm", "95 cm", "100 cm", "105 cm", "110 cm", "115 cm", "120 cm",
            ]
        case .productDimension:
            if card.direction == .metricToImperial {
                return [
                    "4 inches", "6 inches", "8 inches", "10 inches", "12 inches / 1 foot",
                    "16 inches", "20 inches", "2 feet", "2.5 feet", "3 feet",
                    "1 meter / 3.3 feet", "4 feet", "5 feet", "6 feet", "6.5 feet",
                ]
            }
            return [
                "10 cm", "15 cm", "20 cm", "25 cm", "30 cm", "40 cm", "50 cm", "60 cm",
                "75 cm", "90 cm", "100 cm", "120 cm", "150 cm", "180 cm", "200 cm",
            ]
        }
    }
}

enum ShopFormatting {
    static func displayAnswer(for card: ShopCard, label: String) -> String {
        label
    }
}
