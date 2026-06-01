import Foundation

enum GameEngine {
    static func allQuestions(upToRound round: Int) -> [TemperatureQuestion] {
        TemperatureDeck.cards
            .filter { $0.round <= round }
            .flatMap { card in
                ConversionDirection.allCases.map { direction in
                    TemperatureQuestion(card: card, direction: direction)
                }
            }
    }

    static func questions(forRound round: Int) -> [TemperatureQuestion] {
        TemperatureDeck.cards(in: round).flatMap { card in
            ConversionDirection.allCases.map { TemperatureQuestion(card: card, direction: direction) }
        }
    }

    static func unlockedRound(progress: ProgressByQuestion) -> Int {
        var unlocked = 1
        while unlocked < TemperatureDeck.maxRound {
            let roundQuestions = questions(forRound: unlocked)
            let roundComplete = roundQuestions.allSatisfy { progress[$0.key]?.learned == true }
            if roundComplete {
                unlocked += 1
            } else {
                break
            }
        }
        return unlocked
    }

    static func isRoundComplete(_ round: Int, progress: ProgressByQuestion) -> Bool {
        questions(forRound: round).allSatisfy { progress[$0.key]?.learned == true }
    }

    static func chooseQuestion(
        from pool: [TemperatureQuestion],
        progress: ProgressByQuestion,
        excluding previousKey: String?
    ) -> TemperatureQuestion? {
        guard !pool.isEmpty else { return nil }

        var weighted: [TemperatureQuestion] = []
        for question in pool {
            let stats = progress[question.key] ?? QuestionProgress()
            let needsReview = stats.wrong > 0 && stats.streak == 0 && !stats.learned
            let isPriorRound = question.card.round < unlockedRound(progress: progress)

            let weight: Int
            if stats.learned {
                weight = isPriorRound ? 1 : 2
            } else if needsReview {
                weight = 12
            } else {
                weight = max(4, 8 - min(stats.streak, 4))
            }

            weighted.append(contentsOf: Array(repeating: question, count: weight))
        }

        let filtered = weighted.filter { $0.key != previousKey }
        let choices = filtered.isEmpty ? weighted : filtered
        return choices.randomElement()
    }

    static func questionCopy(for question: TemperatureQuestion) -> QuestionCopy {
        switch question.direction {
        case .celsiusToFahrenheit:
            return QuestionCopy(
                prompt: "Match this on the Fahrenheit thermometer",
                givenValue: question.card.celsius,
                givenUnit: "°C",
                target: question.card.fahrenheit,
                answerUnit: "°F",
                tolerance: GameConstants.fahrenheitTolerance,
                correctSummary: "\(question.card.celsius)°C is about \(question.card.fahrenheit)°F.",
                sliderMin: TemperatureDeck.environmentalFahrenheitRange.lowerBound,
                sliderMax: TemperatureDeck.environmentalFahrenheitRange.upperBound
            )
        case .fahrenheitToCelsius:
            return QuestionCopy(
                prompt: "Which Celsius value is closest?",
                givenValue: question.card.fahrenheit,
                givenUnit: "°F",
                target: question.card.celsius,
                answerUnit: "°C",
                tolerance: GameConstants.celsiusTolerance,
                correctSummary: "\(question.card.fahrenheit)°F is about \(question.card.celsius)°C.",
                sliderMin: -30,
                sliderMax: 50
            )
        }
    }

    static func multipleChoiceOptions(for question: TemperatureQuestion) -> [Int] {
        let target = question.card.celsius
        var offsets = [-10, -8, -5, -3, -2, 2, 3, 5, 8, 10, 12]
        if question.card.fahrenheit < 20 {
            offsets = [-8, -6, -4, -2, 2, 4, 6, 8]
        }

        var options = Set<Int>([target])
        for offset in offsets.shuffled() {
            guard options.count < 4 else { break }
            let candidate = target + offset
            if (-30...50).contains(candidate) {
                options.insert(candidate)
            }
        }

        var attempt = 0
        while options.count < 4 && attempt < 40 {
            let filler = target + Int.random(in: -15...15)
            if (-30...50).contains(filler) {
                options.insert(filler)
            }
            attempt += 1
        }

        return Array(options).sorted()
    }

    static func startingSliderValue(for copy: QuestionCopy) -> Int {
        let midpoint = (copy.sliderMin + copy.sliderMax) / 2
        if abs(midpoint - copy.target) > copy.tolerance {
            return midpoint
        }
        return abs(copy.sliderMin - copy.target) > copy.tolerance ? copy.sliderMin : copy.sliderMax
    }
}

struct QuestionCopy {
    let prompt: String
    let givenValue: Int
    let givenUnit: String
    let target: Int
    let answerUnit: String
    let tolerance: Int
    let correctSummary: String
    let sliderMin: Int
    let sliderMax: Int
}

enum RoundTips {
    static let placeholders: [String] = [
        "Placeholder tip: Doubling Celsius and adding 30 gives a rough Fahrenheit estimate for outdoor weather.",
        "Placeholder tip: From Fahrenheit, subtract 30 and halve for a quick Celsius guess.",
        "Placeholder tip: Anchor on 0°C = 32°F, 10°C = 50°F, and 20°C = 68°F before filling gaps.",
        "Placeholder tip: Precision is not the goal — you are learning neighborhoods, not calculator answers.",
        "Placeholder tip: Each 5°C step is roughly 9°F — Celsius climbs more slowly than Fahrenheit.",
        "Placeholder tip: If 15°C feels like 60°F, then 25°C is about 18°F warmer — upper seventies.",
    ]

    static func tip(forRound round: Int) -> String {
        let index = max(0, round - 1) % placeholders.count
        return placeholders[index]
    }
}
