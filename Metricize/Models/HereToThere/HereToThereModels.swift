//
//  HereToThereModels.swift
//  Metricize
//

import Foundation

enum HereToThereCardKind: String, Codable, CaseIterable {
    case smallLength
    case everydayDistance
    case livingArea
    case sheetGoods
    case constructionLumber
}

enum HereToThereConversionDirection: String, Codable, CaseIterable {
    case metricToImperial
    case imperialToMetric
}

enum HereToThereChallengeType: String, Codable, CaseIterable {
    case multipleChoice
}

enum HereToThereRoundKind: Equatable {
    case learning
    case finalExam
}

struct HereToThereCard: Identifiable, Codable, Equatable {
    let id: String
    let roundIndex: Int
    let kind: HereToThereCardKind
    let direction: HereToThereConversionDirection
    let challengeType: HereToThereChallengeType
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
        "Choose the closest practical approximation."
    }

    init(
        roundIndex: Int,
        kind: HereToThereCardKind,
        direction: HereToThereConversionDirection,
        challengeType: HereToThereChallengeType = .multipleChoice,
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
            self.id = "htt-r\(roundIndex)-\(direction.rawValue)-\(Self.stableIDComponent(from: prompt))"
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
            .replacingOccurrences(of: "×", with: "x")
    }
}

struct HereToThereRound: Identifiable {
    let index: Int
    let title: String
    let kind: HereToThereRoundKind
    let cards: [HereToThereCard]

    var id: Int { index }

    var isFinalExam: Bool { kind == .finalExam }

    var subRoundCount: Int {
        isFinalExam ? 1 : HereToThereGameConstants.subRoundsPerRound
    }

    var anchorCount: Int {
        cards.filter { $0.direction == .metricToImperial }.count
    }
}

struct HereToThereFinalExamSession: Codable, Equatable {
    var questions: [HereToThereCard]
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

enum HereToThereGameConstants {
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

enum HereToThereConversion {
    enum AnswerResult {
        case exact
        case incorrect
    }

    static func evaluate(guess: Int, correctIndex: Int) -> AnswerResult {
        guess == correctIndex ? .exact : .incorrect
    }

    static func distractorLabels(for card: HereToThereCard) -> [String] {
        switch card.kind {
        case .smallLength:
            if card.direction == .metricToImperial {
                return [
                    "1/4 inch", "3/8 inch", "1/2 inch", "3/4 inch", "1 inch",
                    "2 inches", "3 inches", "4 inches", "6 inches", "8 inches",
                    "10 inches", "12 inches / 1 foot",
                ]
            }
            return [
                "5 mm", "10 mm", "12 mm", "20 mm", "25 mm",
                "50 mm", "75 mm", "100 mm", "150 mm", "200 mm",
                "250 mm", "300 mm",
            ]
        case .everydayDistance:
            if card.direction == .metricToImperial {
                return [
                    "1 foot", "18 inches", "2 feet", "2.5 feet", "3 feet / 1 yard",
                    "3.3 feet", "4 feet", "5 feet", "6 feet", "6.5 feet", "8 feet", "10 feet",
                ]
            }
            return [
                "30 cm", "45 cm", "60 cm", "75 cm", "90 cm",
                "1 m", "1.2 m", "1.5 m", "1.8 m", "2 m", "2.4 m", "3 m",
            ]
        case .livingArea:
            if card.direction == .metricToImperial {
                return [
                    "100 sq ft", "160 sq ft", "215 sq ft", "270 sq ft", "325 sq ft",
                    "430 sq ft", "540 sq ft", "650 sq ft", "800 sq ft", "1,000 sq ft",
                    "1,300 sq ft", "1,600 sq ft",
                ]
            }
            return [
                "10 m²", "15 m²", "20 m²", "25 m²", "30 m²",
                "40 m²", "50 m²", "60 m²", "75 m²", "90 m²", "120 m²", "150 m²",
            ]
        case .sheetGoods:
            if card.direction == .metricToImperial {
                return [
                    "1/4 inch", "3/8 inch", "1/2 inch", "3/4 inch",
                    "2 feet", "3 feet", "4 feet", "8 feet",
                    "4 × 8 ft sheet", "close to 4 × 8 ft sheet",
                    "1 × 2 nominal lumber", "2 × 4 nominal lumber",
                ]
            }
            return [
                "6 mm", "9 mm", "12 mm", "18 mm",
                "600 mm", "900 mm", "1,200 mm", "2,400 mm",
                "1,220 × 2,440 mm sheet", "1,200 × 2,400 mm sheet",
                "19 × 38 mm", "38 × 89 mm",
            ]
        case .constructionLumber:
            if card.direction == .metricToImperial {
                return [
                    "1 × 2 lumber", "1 × 3 lumber", "1 × 4 lumber",
                    "2 × 4 lumber", "2 × 6 lumber", "4 × 4 post",
                    "4 inches", "6 inches", "12 inches / 1 foot",
                    "18 inches", "2 feet", "3 feet", "4 feet", "6 feet", "8 feet",
                ]
            }
            return [
                "25 × 50 mm", "25 × 75 mm", "25 × 100 mm",
                "38 × 89 mm", "38 × 140 mm", "89 × 89 mm",
                "100 mm", "150 mm", "300 mm", "450 mm",
                "600 mm", "900 mm", "1,200 mm", "1,800 mm", "2,400 mm",
            ]
        }
    }
}

enum HereToThereFormatting {
    static func displayAnswer(for card: HereToThereCard, label: String) -> String {
        label
    }
}
