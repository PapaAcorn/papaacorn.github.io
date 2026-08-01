//
//  TemperatureCurriculum.swift
//  Metricize
//

import Foundation

enum TemperatureCurriculum {
    static let rounds: [TemperatureRound] = [
        TemperatureRound(
            index: 0,
            title: "Fahrenheit Milestones",
            kind: .learning,
            cards: cards(
                forRound: 0,
                fahrenheitValues: [32, 68, 99, 0, 50],
                labels: [
                    "Freezing point of water",
                    "Standard indoor room temperature",
                    "Standard human body temperature",
                    "Extremely cold — well below freezing",
                    "Cool spring or fall day",
                ]
            )
        ),
        TemperatureRound(
            index: 1,
            title: "Celsius Tens",
            kind: .learning,
            cards: cards(
                forRound: 1,
                celsiusValues: [-20, -10, 0, 10, 30],
                labels: [
                    "Deep winter cold",
                    "Bitter cold morning",
                    "Freezing point of water",
                    "Cool but above freezing",
                    "Hot summer day",
                ]
            )
        ),
        TemperatureRound(
            index: 2,
            title: "Celsius Fives",
            kind: .learning,
            cards: cards(
                forRound: 2,
                celsiusValues: [-15, -5, 5, 15, 25],
                labels: [
                    "Frigid outdoors",
                    "Just below freezing",
                    "Light jacket weather",
                    "Mild spring or fall afternoon",
                    "Warm afternoon",
                ]
            )
        ),
        TemperatureRound(
            index: TemperatureGameConstants.finalExamRoundIndex,
            title: "Final Exam",
            kind: .finalExam,
            cards: []
        ),
    ]

    static let roundIntroTips: [Int: [String]] = [
        0: [
            "In this round you'll learn common Fahrenheit milestones: freezing (32°F), comfortable room temperature (68°F), human body temperature (99°F), and a few more everyday reference points.",
            "You'll practice converting these to Celsius and back until they start to feel automatic.",
        ],
        1: [
            "This round teaches the Celsius tens: -20, -10, 0, 10, and 30 degrees.",
            "These anchors are the backbone of your mental scale — once you know the tens, you can estimate anything nearby.",
        ],
        2: [
            "Now you'll learn the fives that sit between those tens: -15, -5, 5, 15, and 25.",
            "This fills in the gaps so your Celsius intuition feels continuous, not jumpy.",
        ],
    ]

    static let finalExamIntroTips: [String] = [
        "Treat this like a low-stress game — not a test you need to ace on the first try.",
        "You'll see some temperatures we haven't practiced together. Use what you have learned to estimate, the way you would in real life when someone mentions an unfamiliar number.",
        "The goal is to show you that you can get by when you need to understand ambient temperature — close enough counts using your accuracy setting from Settings.",
        "You need 80% correct to pass. Score below that and we recommend reviewing earlier modules before trying again.",
    ]

    static func tips(forRound roundIndex: Int) -> [String] {
        if roundIndex == TemperatureGameConstants.finalExamRoundIndex {
            return finalExamIntroTips
        }
        let tips = roundIntroTips[roundIndex] ?? [
            "Practice makes approximation instinctive.",
        ]
        return tips
    }

    static func roundTitle(for roundIndex: Int) -> String {
        rounds.first(where: { $0.index == roundIndex })?.title ?? "Round \(roundIndex + 1)"
    }

    static var learningRounds: [TemperatureRound] {
        rounds.filter { $0.kind == .learning }
    }

    static var allCards: [TemperatureCard] {
        learningRounds.flatMap(\.cards)
    }

    static func cards(forRound index: Int) -> [TemperatureCard] {
        rounds.first(where: { $0.index == index })?.cards ?? []
    }

    static func cards(forRound roundIndex: Int, subRoundIndex: Int) -> [TemperatureCard] {
        guard let round = rounds.first(where: { $0.index == roundIndex }), round.kind == .learning else {
            return []
        }
        let all = round.cards
        switch subRoundIndex {
        case 0:
            return all.filter { $0.direction == .celsiusToFahrenheit }
        case 1:
            return all.filter { $0.direction == .fahrenheitToCelsius }
        case TemperatureGameConstants.mixedSubRoundIndex:
            return all
        default:
            return all
        }
    }

    static func subRoundLabel(majorRoundIndex: Int, subRoundIndex: Int) -> String {
        if majorRoundIndex == TemperatureGameConstants.finalExamRoundIndex {
            return "4"
        }
        return "\(majorRoundIndex + 1).\(subRoundIndex + 1)"
    }

    static func pathLabel(roundIndex: Int, subRoundIndex: Int) -> String {
        if rounds.first(where: { $0.index == roundIndex })?.isFinalExam == true {
            return "Exam"
        }
        return subRoundLabel(majorRoundIndex: roundIndex, subRoundIndex: subRoundIndex)
    }

    static func roundReviewItems(forRound roundIndex: Int) -> [ConversionReviewItem] {
        subRoundReviewItems(forRound: roundIndex, subRoundIndex: 0)
            + subRoundReviewItems(forRound: roundIndex, subRoundIndex: 1)
    }

    static func subRoundReviewItems(forRound roundIndex: Int, subRoundIndex: Int) -> [ConversionReviewItem] {
        cards(forRound: roundIndex, subRoundIndex: subRoundIndex).map { card in
            ConversionReviewItem(
                id: card.id,
                source: reviewSource(for: card),
                target: reviewTarget(for: card)
            )
        }
    }

    static func reviewSource(for card: TemperatureCard) -> String {
        "\(card.promptValue)\(card.promptUnit)"
    }

    static func reviewTarget(for card: TemperatureCard) -> String {
        "\(card.correctAnswer)\(card.answerUnit)"
    }

    static func generateFinalExamQuestions(count: Int = TemperatureGameConstants.examQuestionCount) -> [TemperatureCard] {
        var questions: [TemperatureCard] = []
        var usedKeys = Set<String>()
        let maxAttempts = count * 40
        var attempts = 0

        while questions.count < count, attempts < maxAttempts {
            attempts += 1
            let celsius = Int.random(in: TemperatureGameConstants.examCelsiusRange)
            let fahrenheit = TemperatureConversion.fahrenheit(fromCelsius: celsius)
            guard TemperatureGameConstants.examFahrenheitRange.contains(fahrenheit) else { continue }

            let direction: ConversionDirection = Bool.random() ? .celsiusToFahrenheit : .fahrenheitToCelsius
            let key = "\(celsius)-\(direction.rawValue)"
            guard !usedKeys.contains(key) else { continue }
            usedKeys.insert(key)

            questions.append(
                TemperatureCard(
                    celsius: celsius,
                    roundIndex: TemperatureGameConstants.finalExamRoundIndex,
                    challengeType: .multipleChoice,
                    direction: direction,
                    label: nil,
                    examQuestionID: "exam-q\(questions.count)-\(key)"
                )
            )
        }

        return questions
    }

    private static func cards(
        forRound roundIndex: Int,
        fahrenheitValues: [Int],
        labels: [String]
    ) -> [TemperatureCard] {
        let celsiusValues = fahrenheitValues.map { TemperatureConversion.celsius(fromFahrenheit: $0) }
        return cards(forRound: roundIndex, celsiusValues: celsiusValues, labels: labels)
    }

    private static func cards(
        forRound roundIndex: Int,
        celsiusValues: [Int],
        labels: [String]
    ) -> [TemperatureCard] {
        zip(celsiusValues, labels).enumerated().flatMap { offset, pair in
            let cToFType: ChallengeType = offset.isMultiple(of: 2) ? .thermometerSlider : .multipleChoice
            let fToCType: ChallengeType = offset.isMultiple(of: 2) ? .multipleChoice : .thermometerSlider
            return [
                TemperatureCard(
                    celsius: pair.0,
                    roundIndex: roundIndex,
                    challengeType: cToFType,
                    direction: .celsiusToFahrenheit,
                    label: pair.1
                ),
                TemperatureCard(
                    celsius: pair.0,
                    roundIndex: roundIndex,
                    challengeType: fToCType,
                    direction: .fahrenheitToCelsius,
                    label: pair.1
                ),
            ]
        }
    }
}
