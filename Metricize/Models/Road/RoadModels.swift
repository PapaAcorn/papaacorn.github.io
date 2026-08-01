//
//  RoadModels.swift
//  Metricize
//

import Foundation

enum RoadCardKind: String, Codable, CaseIterable {
    case speed
    case shortDistance
    case walkingDistance
    case drivingDistance
    case travelTimeAnchor
}

enum RoadConversionDirection: String, Codable, CaseIterable {
    case metricToImperial
    case imperialToMetric
}

enum RoadChallengeType: String, Codable, CaseIterable {
    case multipleChoice
}

enum RoadRoundKind: Equatable {
    case learning
    case finalExam
}

struct RoadCard: Identifiable, Codable, Equatable {
    let id: String
    let roundIndex: Int
    let kind: RoadCardKind
    let direction: RoadConversionDirection
    let challengeType: RoadChallengeType
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
        kind: RoadCardKind,
        direction: RoadConversionDirection,
        challengeType: RoadChallengeType = .multipleChoice,
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
            self.id = "r-r\(roundIndex)-\(direction.rawValue)-\(Self.stableIDComponent(from: prompt))"
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

struct RoadRound: Identifiable {
    let index: Int
    let title: String
    let kind: RoadRoundKind
    let cards: [RoadCard]

    var id: Int { index }

    var isFinalExam: Bool { kind == .finalExam }

    var subRoundCount: Int {
        isFinalExam ? 1 : RoadGameConstants.subRoundsPerRound
    }

    var anchorCount: Int {
        cards.filter { $0.direction == .metricToImperial }.count
    }
}

struct RoadFinalExamSession: Codable, Equatable {
    var questions: [RoadCard]
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

enum RoadGameConstants {
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

enum RoadConversion {
    enum AnswerResult {
        case exact
        case incorrect
    }

    static func evaluate(guess: Int, correctIndex: Int) -> AnswerResult {
        guess == correctIndex ? .exact : .incorrect
    }

    static func distractorLabels(for card: RoadCard) -> [String] {
        switch card.kind {
        case .speed:
            if card.direction == .metricToImperial {
                return ["6 mph", "12 mph", "20 mph", "25 mph", "30 mph", "35 mph", "45 mph", "50 mph", "55 mph", "60 mph", "70 mph", "75 mph", "80 mph"]
            }
            return ["10 km/h", "20 km/h", "30 km/h", "40 km/h", "50 km/h", "60 km/h", "70 km/h", "80 km/h", "90 km/h", "100 km/h", "110 km/h", "120 km/h", "130 km/h"]
        case .shortDistance:
            if card.direction == .metricToImperial {
                return ["80 ft", "165 ft", "250 ft", "330 ft", "500 ft", "650 ft", "820 ft", "1,000 ft", "1/4 mile", "1/3 mile"]
            }
            return ["25 m", "50 m", "75 m", "100 m", "150 m", "200 m", "250 m", "300 m", "400 m", "500 m"]
        case .walkingDistance:
            if card.direction == .metricToImperial {
                return ["0.4 miles", "0.5 miles", "0.6 miles", "0.75 miles", "1 mile", "1.25 miles", "1.5 miles", "2 miles", "2.5 miles", "3 miles"]
            }
            return ["600 m", "750 m", "1 km", "1.2 km", "1.5 km", "2 km", "2.5 km", "3 km", "4 km", "5 km"]
        case .drivingDistance:
            if card.direction == .metricToImperial {
                return ["6 miles", "9 miles", "12 miles", "15 miles", "20 miles", "25 miles", "30 miles", "45 miles", "60 miles", "90 miles", "125 miles", "185 miles"]
            }
            return ["10 km", "15 km", "20 km", "25 km", "30 km", "40 km", "50 km", "75 km", "100 km", "150 km", "200 km", "300 km"]
        case .travelTimeAnchor:
            return travelTimeDistractors(for: card)
        }
    }

    private static func travelTimeDistractors(for card: RoadCard) -> [String] {
        if card.direction == .metricToImperial {
            return [
                "About 20 miles", "About 30 miles", "About 60 miles",
                "60 mph", "75 mph",
                "About 50 km", "About 100 km",
                "A short local drive",
            ]
        }
        return [
            "About 10 km", "About 30 km", "About 50 km", "About 100 km",
            "100 km/h", "120 km/h",
            "About 50 km", "About 100 km",
            "A short local drive",
        ]
    }
}

enum RoadFormatting {
    static func displayAnswer(for card: RoadCard, label: String) -> String {
        label
    }
}
