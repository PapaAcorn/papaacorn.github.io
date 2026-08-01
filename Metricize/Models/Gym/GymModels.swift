//
//  GymModels.swift
//  Metricize
//

import Foundation

enum GymCardKind: String, Codable, CaseIterable {
    case bodyWeight
    case lightWeight
    case heavyWeight
    case plateAndBarbell
    case cardioSpeed
}

enum GymConversionDirection: String, Codable, CaseIterable {
    case metricToImperial
    case imperialToMetric
}

enum GymChallengeType: String, Codable, CaseIterable {
    case multipleChoice
}

enum GymRoundKind: Equatable {
    case learning
    case finalExam
}

struct GymCard: Identifiable, Codable, Equatable {
    let id: String
    let roundIndex: Int
    let kind: GymCardKind
    let direction: GymConversionDirection
    let challengeType: GymChallengeType
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
        kind: GymCardKind,
        direction: GymConversionDirection,
        challengeType: GymChallengeType = .multipleChoice,
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
            self.id = "g-r\(roundIndex)-\(direction.rawValue)-\(Self.stableIDComponent(from: prompt))"
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

struct GymRound: Identifiable {
    let index: Int
    let title: String
    let kind: GymRoundKind
    let cards: [GymCard]

    var id: Int { index }

    var isFinalExam: Bool { kind == .finalExam }

    var subRoundCount: Int {
        isFinalExam ? 1 : GymGameConstants.subRoundsPerRound
    }

    var anchorCount: Int {
        cards.filter { $0.direction == .metricToImperial }.count
    }
}

struct GymFinalExamSession: Codable, Equatable {
    var questions: [GymCard]
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

enum GymGameConstants {
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

enum GymConversion {
    enum AnswerResult {
        case exact
        case incorrect
    }

    static func evaluate(guess: Int, correctIndex: Int) -> AnswerResult {
        guess == correctIndex ? .exact : .incorrect
    }

    static func distractorLabels(for card: GymCard) -> [String] {
        switch card.kind {
        case .bodyWeight:
            if card.direction == .metricToImperial {
                return [
                    "110 lb", "120 lb", "130 lb", "145 lb", "155 lb", "165 lb", "175 lb", "185 lb",
                    "200 lb", "210 lb", "220 lb", "240 lb", "265 lb", "300 lb", "330 lb",
                ]
            }
            return [
                "50 kg", "55 kg", "60 kg", "65 kg", "70 kg", "75 kg", "80 kg", "85 kg",
                "90 kg", "95 kg", "100 kg", "110 kg", "120 kg", "135 kg", "150 kg",
            ]
        case .lightWeight:
            if card.direction == .metricToImperial {
                return [
                    "2 lb", "4 lb", "7 lb", "9 lb", "11 lb", "13 lb", "18 lb", "22 lb",
                    "26 lb", "30 lb", "35 lb", "40 lb", "44 lb", "50 lb", "53 lb",
                ]
            }
            return [
                "1 kg", "2 kg", "3 kg", "4 kg", "5 kg", "6 kg", "8 kg", "10 kg",
                "12 kg", "14 kg", "16 kg", "18 kg", "20 kg", "22 kg", "24 kg",
            ]
        case .heavyWeight:
            if card.direction == .metricToImperial {
                return [
                    "55 lb", "65 lb", "75 lb", "90 lb", "100 lb", "110 lb", "135 lb", "155 lb",
                    "175 lb", "200 lb", "220 lb", "265 lb", "310 lb", "350 lb", "400 lb",
                ]
            }
            return [
                "25 kg", "30 kg", "35 kg", "40 kg", "45 kg", "50 kg", "60 kg", "70 kg",
                "80 kg", "90 kg", "100 kg", "120 kg", "140 kg", "160 kg", "180 kg",
            ]
        case .plateAndBarbell:
            if card.direction == .metricToImperial {
                return [
                    "11 lb", "22 lb", "33 lb", "44 lb", "55 lb", "45 lb",
                    "65 lb", "90 lb", "135 lb", "175 lb", "220 lb", "265 lb",
                ]
            }
            return [
                "5 kg", "10 kg", "15 kg", "20 kg", "25 kg", "20 kg",
                "30 kg", "40 kg", "60 kg", "80 kg", "100 kg", "120 kg",
            ]
        case .cardioSpeed:
            if card.direction == .metricToImperial {
                return [
                    "2 mph", "3 mph", "4 mph", "5 mph", "6 mph", "7 mph",
                    "8 mph", "9 mph", "10 mph", "12 mph", "15 mph", "19 mph",
                ]
            }
            return [
                "3 km/h", "5 km/h", "6 km/h", "8 km/h", "10 km/h", "11 km/h",
                "13 km/h", "14.5 km/h", "16 km/h", "20 km/h", "24 km/h", "30 km/h",
            ]
        }
    }
}

enum GymFormatting {
    static func displayAnswer(for card: GymCard, label: String) -> String {
        label
    }
}
