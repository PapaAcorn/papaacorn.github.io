//
//  KitchenCurriculum.swift
//  Metricize
//

import Foundation

enum KitchenCurriculum {
    static let rounds: [KitchenRound] = [
        KitchenRound(
            index: 0,
            title: "Core Kitchen Anchors",
            kind: .learning,
            cards: round1Cards
        ),
        KitchenRound(
            index: 1,
            title: "Common Recipe Quantities",
            kind: .learning,
            cards: round2Cards
        ),
        KitchenRound(
            index: 2,
            title: "Baking Weight Intuition",
            kind: .learning,
            cards: round3Cards
        ),
        KitchenRound(
            index: 3,
            title: "Oven & Food Safety Temps",
            kind: .learning,
            cards: round4Cards
        ),
        KitchenRound(
            index: 4,
            title: "Pan & Dish Sizes",
            kind: .learning,
            cards: round5Cards
        ),
        KitchenRound(
            index: KitchenGameConstants.finalExamRoundIndex,
            title: "Final Exam",
            kind: .finalExam,
            cards: []
        ),
    ]

    // MARK: - Round 1: Core Kitchen Anchors

    private static let round1Cards: [KitchenCard] = pairedCards(
        roundIndex: 0,
        anchors: [
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "1 teaspoon",
                metricPrompt: "5 mL",
                metricAnswer: 5,
                metricUnit: " mL",
                reverseAnswer: 1,
                reverseUnit: " tsp",
                label: "Standard small spoon measure"
            ),
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "1 tablespoon",
                metricPrompt: "15 mL",
                metricAnswer: 15,
                metricUnit: " mL",
                reverseAnswer: 1,
                reverseUnit: " tbsp",
                label: "3 teaspoons"
            ),
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "1 fluid ounce",
                metricPrompt: "30 mL",
                metricAnswer: 30,
                metricUnit: " mL",
                reverseAnswer: 1,
                reverseUnit: " fl oz",
                label: "Common liquid shot size"
            ),
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "1 cup",
                metricPrompt: "240 mL",
                metricAnswer: 240,
                metricUnit: " mL",
                reverseAnswer: 1,
                reverseUnit: " cup",
                label: "Standard US cup — about 240 mL"
            ),
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "1 pint",
                metricPrompt: "500 mL",
                metricAnswer: 500,
                metricUnit: " mL",
                reverseAnswer: 1,
                reverseUnit: " pint",
                label: "About half a liter"
            ),
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "1 quart",
                metricPrompt: "1 liter",
                metricPromptValue: 1000,
                metricAnswer: 1000,
                metricUnit: " mL",
                reverseAnswer: 1,
                reverseUnit: " quart",
                label: "About 1 liter — good enough for cooking"
            ),
            KitchenAnchorPair(
                kind: .weight,
                imperialPrompt: "1 ounce (by weight)",
                metricPrompt: "30 g",
                metricAnswer: 30,
                metricUnit: " g",
                reverseAnswer: 1,
                reverseUnit: " oz",
                label: "Handy weight shortcut"
            ),
            KitchenAnchorPair(
                kind: .weight,
                imperialPrompt: "1 pound",
                metricPrompt: "450 g",
                metricAnswer: 450,
                metricUnit: " g",
                reverseAnswer: 1,
                reverseUnit: " lb",
                label: "About 450 g per pound"
            ),
        ]
    )

    // MARK: - Round 2: Common Recipe Quantities

    private static let round2Cards: [KitchenCard] = pairedCards(
        roundIndex: 1,
        anchors: [
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "1/4 teaspoon",
                metricPrompt: "1 mL",
                metricAnswer: 1,
                metricUnit: " mL",
                reverseAnswer: 1,
                reverseUnit: " quarter-tsp",
                label: "A tiny pinch — about 1 mL"
            ),
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "1/2 teaspoon",
                metricPrompt: "2.5 mL",
                metricPromptValue: 3,
                metricAnswer: 3,
                metricUnit: " mL",
                reverseAnswer: 1,
                reverseUnit: " half-tsp",
                label: "Half a teaspoon — about 3 mL"
            ),
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "2 teaspoons",
                metricPrompt: "10 mL",
                metricAnswer: 10,
                metricUnit: " mL",
                reverseAnswer: 2,
                reverseUnit: " tsp",
                label: "Double a teaspoon"
            ),
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "1/4 cup",
                metricPrompt: "60 mL",
                metricAnswer: 60,
                metricUnit: " mL",
                reverseAnswer: 1,
                reverseUnit: " quarter-cup",
                label: "One quarter of a cup — think 60 mL"
            ),
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "1/3 cup",
                metricPrompt: "80 mL",
                metricAnswer: 80,
                metricUnit: " mL",
                reverseAnswer: 1,
                reverseUnit: " third-cup",
                label: "A third of a cup"
            ),
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "1/2 cup",
                metricPrompt: "120 mL",
                metricAnswer: 120,
                metricUnit: " mL",
                reverseAnswer: 1,
                reverseUnit: " half-cup",
                label: "Half a cup — half of 240 mL"
            ),
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "3/4 cup",
                metricPrompt: "180 mL",
                metricAnswer: 180,
                metricUnit: " mL",
                reverseAnswer: 1,
                reverseUnit: " three-quarter-cup",
                label: "Three quarters of a cup"
            ),
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "2 cups",
                metricPrompt: "480 mL",
                metricAnswer: 480,
                metricUnit: " mL",
                reverseAnswer: 2,
                reverseUnit: " cups",
                label: "About half a liter"
            ),
            KitchenAnchorPair(
                kind: .volume,
                imperialPrompt: "4 cups",
                metricPrompt: "1 liter",
                metricPromptValue: 1000,
                metricAnswer: 1000,
                metricUnit: " mL",
                reverseAnswer: 4,
                reverseUnit: " cups",
                label: "About 1 liter — a common batch size"
            ),
        ]
    )

    // MARK: - Round 3: Baking Weight Intuition
    // Ingredient-specific weights — 1 cup does not always weigh the same.

    private static let round3Cards: [KitchenCard] = pairedCards(
        roundIndex: 2,
        anchors: [
            KitchenAnchorPair(
                kind: .weight,
                imperialPrompt: "1 cup all-purpose flour",
                metricPrompt: "120 g flour",
                metricAnswer: 120,
                metricUnit: " g",
                reverseAnswer: 1,
                reverseUnit: " cup flour",
                label: "Flour is lighter than you might expect"
            ),
            KitchenAnchorPair(
                kind: .weight,
                imperialPrompt: "1 cup granulated sugar",
                metricPrompt: "200 g sugar",
                metricAnswer: 200,
                metricUnit: " g",
                reverseAnswer: 1,
                reverseUnit: " cup sugar",
                label: "Sugar is denser than flour"
            ),
            KitchenAnchorPair(
                kind: .weight,
                imperialPrompt: "1 cup packed brown sugar",
                metricPrompt: "220 g brown sugar",
                metricAnswer: 220,
                metricUnit: " g",
                reverseAnswer: 1,
                reverseUnit: " cup brown sugar",
                label: "Packed brown sugar weighs more"
            ),
            KitchenAnchorPair(
                kind: .weight,
                imperialPrompt: "1 stick butter (1/2 cup)",
                metricPrompt: "113 g butter",
                metricAnswer: 113,
                metricUnit: " g",
                reverseAnswer: 1,
                reverseUnit: " stick butter",
                label: "One stick = 1/2 cup = about 113 g"
            ),
            KitchenAnchorPair(
                kind: .weight,
                imperialPrompt: "1 tablespoon butter",
                metricPrompt: "14 g butter",
                metricAnswer: 14,
                metricUnit: " g",
                reverseAnswer: 1,
                reverseUnit: " tbsp butter",
                label: "A pat of butter"
            ),
            KitchenAnchorPair(
                kind: .weight,
                imperialPrompt: "1 cup dry rice",
                metricPrompt: "190 g rice",
                metricAnswer: 190,
                metricUnit: " g",
                reverseAnswer: 1,
                reverseUnit: " cup rice",
                label: "About 190 g per cup of dry rice"
            ),
            KitchenAnchorPair(
                kind: .weight,
                imperialPrompt: "1 ounce dry pasta",
                metricPrompt: "28 g pasta",
                metricAnswer: 28,
                metricUnit: " g",
                reverseAnswer: 1,
                reverseUnit: " oz pasta",
                label: "A single serving by weight"
            ),
        ]
    )

    // MARK: - Round 4: Oven & Food Safety Temps

    private static let round4Cards: [KitchenCard] = {
        let ovenCards = pairedTemperatureCards(
            roundIndex: 3,
            anchors: [
                KitchenTemperatureAnchor(fahrenheit: 300, celsius: 150, label: "Low oven"),
                KitchenTemperatureAnchor(fahrenheit: 325, celsius: 160, label: "Gentle baking"),
                KitchenTemperatureAnchor(fahrenheit: 350, celsius: 175, label: "Standard baking"),
                KitchenTemperatureAnchor(fahrenheit: 375, celsius: 190, label: "Roasting / baking"),
                KitchenTemperatureAnchor(fahrenheit: 400, celsius: 200, label: "Hot oven"),
                KitchenTemperatureAnchor(fahrenheit: 425, celsius: 220, label: "High roasting"),
                KitchenTemperatureAnchor(fahrenheit: 450, celsius: 230, label: "Very hot oven"),
            ],
            kind: .ovenTemperature
        )

        let safetyCards = foodSafetyCards(
            roundIndex: 3,
            anchors: [
                KitchenSafetyAnchor(
                    fahrenheit: 145,
                    celsius: 63,
                    label: "Whole cuts of beef, pork, veal, and lamb — with a 3-minute rest"
                ),
                KitchenSafetyAnchor(
                    fahrenheit: 145,
                    celsius: 63,
                    label: "Fish"
                ),
                KitchenSafetyAnchor(
                    fahrenheit: 160,
                    celsius: 71,
                    label: "Ground beef, pork, veal, and lamb"
                ),
                KitchenSafetyAnchor(
                    fahrenheit: 165,
                    celsius: 74,
                    label: "Poultry, including chicken and turkey"
                ),
                KitchenSafetyAnchor(
                    fahrenheit: 165,
                    celsius: 74,
                    label: "Leftovers and casseroles"
                ),
            ]
        )

        return ovenCards + safetyCards
    }()

    static let roundIntroTips: [Int: [String]] = [
        0: [
            "This round teaches the kitchen equivalents you'll see in almost every recipe: teaspoons, tablespoons, cups, pints, quarts, ounces, and pounds.",
            "Start with liquids: 1 cup of water is 240 mL. These volume anchors are the foundation — memorize them and the rest gets easier.",
        ],
        1: [
            "Now you'll learn common fractional and combined amounts: quarter-cups, half-cups, and multiples.",
            "Think of a cup as about 60 mL per quarter-cup. Once that clicks, recipe math gets much easier.",
        ],
        2: [
            "Dry ingredients do not all weigh the same — 1 cup of flour is not the same as 1 cup of sugar.",
            "For baking, grams are usually better than cups. Learn a few ingredient-specific anchors and you'll read international recipes with confidence.",
        ],
        3: [
            "This round covers oven settings for international recipes and safe internal food temperatures.",
            "Learn the exact oven pairs — 350°F is 175°C. Food safety temps are USDA minimums — use the exact values for meat and poultry.",
        ],
        4: [
            "This round teaches pan and baking-dish equivalents for shopping and cooking in metric countries.",
            "These are closest common household sizes — not exact inch-to-centimeter conversions. Measure pans from the inside edge. For casseroles, close is usually fine; for cakes, area and depth affect baking time.",
        ],
    ]

    static let finalExamIntroTips: [String] = [
        "This final check mixes everything you've learned: volumes, weights, oven temps, and food safety.",
        "Use the anchors you memorized — answers must match the taught values exactly.",
        "Food safety questions require the exact USDA temperatures. Do not guess low on poultry or ground meat.",
        "You need 80% correct to pass — up to 20 questions, each shown once.",
    ]

    static func tips(forRound roundIndex: Int) -> [String] {
        if roundIndex == KitchenGameConstants.finalExamRoundIndex {
            return finalExamIntroTips
        }
        return roundIntroTips[roundIndex] ?? ["Practice makes approximation instinctive."]
    }

    static func roundTitle(for roundIndex: Int) -> String {
        rounds.first(where: { $0.index == roundIndex })?.title ?? "Round \(roundIndex + 1)"
    }

    static var learningRounds: [KitchenRound] {
        rounds.filter { $0.kind == .learning }
    }

    static var allCards: [KitchenCard] {
        learningRounds.flatMap(\.cards)
    }

    static func cards(forRound index: Int) -> [KitchenCard] {
        rounds.first(where: { $0.index == index })?.cards ?? []
    }

    static func cards(forRound roundIndex: Int, subRoundIndex: Int) -> [KitchenCard] {
        guard let round = rounds.first(where: { $0.index == roundIndex }), round.kind == .learning else {
            return []
        }
        let all = round.cards
        switch subRoundIndex {
        case 0:
            return all.filter { $0.direction == .imperialToMetric }
        case 1:
            return all.filter { $0.direction == .metricToImperial }
        case KitchenGameConstants.mixedSubRoundIndex:
            return all
        default:
            return all
        }
    }

    static func subRoundLabel(majorRoundIndex: Int, subRoundIndex: Int) -> String {
        if majorRoundIndex == KitchenGameConstants.finalExamRoundIndex {
            return "6"
        }
        return "\(majorRoundIndex + 1).\(subRoundIndex + 1)"
    }

    static func pathLabel(roundIndex: Int, subRoundIndex: Int) -> String {
        if rounds.first(where: { $0.index == roundIndex })?.isFinalExam == true {
            return "Exam"
        }
        return subRoundLabel(majorRoundIndex: roundIndex, subRoundIndex: subRoundIndex)
    }

    static func batchReviewItems(for cards: [KitchenCard]) -> [ConversionReviewItem] {
        cards.map { card in
            ConversionReviewItem(
                id: card.id,
                source: reviewSource(for: card),
                target: reviewTarget(for: card)
            )
        }
    }

    static func reviewSource(for card: KitchenCard) -> String {
        if let promptValue = card.promptValue, let promptUnit = card.promptUnit {
            return "\(promptValue)\(promptUnit)"
        }
        return card.prompt
    }

    static func reviewTarget(for card: KitchenCard) -> String {
        if let answerLabel = card.answerLabel {
            return answerLabel
        }
        return KitchenFormatting.answerPhrase(value: card.correctAnswer, unit: card.answerUnit)
    }

    static func generateFinalExamQuestions(
        count: Int = KitchenGameConstants.examQuestionCount
    ) -> [KitchenCard] {
        var questions: [KitchenCard] = []
        var usedIDs = Set<String>()

        for kind in KitchenCardKind.allCases {
            guard let template = finalExamQuestionPool.filter({ $0.kind == kind }).randomElement() else { continue }
            guard !usedIDs.contains(template.id) else { continue }
            usedIDs.insert(template.id)
            questions.append(template)
        }

        let shuffled = finalExamQuestionPool.shuffled()
        for template in shuffled where questions.count < count {
            guard !usedIDs.contains(template.id) else { continue }
            usedIDs.insert(template.id)
            questions.append(template)
        }

        var attempt = 0
        while questions.count < count, attempt < count * 10 {
            attempt += 1
            let extras = finalExamQuestionPool.shuffled()
            for template in extras where questions.count < count {
                let uniqueID = "\(template.id)-alt\(attempt)"
                guard !usedIDs.contains(uniqueID) else { continue }
                usedIDs.insert(uniqueID)
                questions.append(
                    KitchenCard(
                        roundIndex: KitchenGameConstants.finalExamRoundIndex,
                        kind: template.kind,
                        direction: template.direction,
                        challengeType: .multipleChoice,
                        prompt: template.prompt,
                        promptValue: template.promptValue,
                        promptUnit: template.promptUnit,
                        correctAnswer: template.correctAnswer,
                        answerUnit: template.answerUnit,
                        label: template.label,
                        requiresExactAnswer: template.requiresExactAnswer,
                        alternateExactAnswer: template.alternateExactAnswer,
                        toleranceOverride: template.toleranceOverride,
                        answerLabel: template.answerLabel,
                        choiceLabels: template.choiceLabels,
                        examQuestionID: uniqueID
                    )
                )
            }
        }

        return Array(questions.prefix(count)).shuffled()
    }

    // MARK: - Final Exam Pool

    private static let finalExamQuestionPool: [KitchenCard] = {
        let examRound = KitchenGameConstants.finalExamRoundIndex
        return [
            // Liquid conversions
            examCard(examRound, prompt: "1 tablespoon", answer: 15, unit: " mL", kind: .volume, direction: .imperialToMetric),
            examCard(examRound, prompt: "1 cup", answer: 240, unit: " mL", kind: .volume, direction: .imperialToMetric),
            examCard(examRound, prompt: "1 liter", promptValue: 1000, answer: 4, unit: " cups", kind: .volume, direction: .metricToImperial, label: "About 4 cups"),
            examCard(examRound, prompt: "1/2 cup", answer: 120, unit: " mL", kind: .volume, direction: .imperialToMetric),
            examCard(examRound, prompt: "1 teaspoon", answer: 5, unit: " mL", kind: .volume, direction: .imperialToMetric),
            examCard(examRound, prompt: "1 fluid ounce", answer: 30, unit: " mL", kind: .volume, direction: .imperialToMetric),
            examCard(examRound, prompt: "1 pint", answer: 500, unit: " mL", kind: .volume, direction: .imperialToMetric),
            examCard(examRound, prompt: "240 mL", answer: 1, unit: " cup", kind: .volume, direction: .metricToImperial),

            // Fractional recipe amounts
            examCard(examRound, prompt: "1/4 cup", answer: 60, unit: " mL", kind: .volume, direction: .imperialToMetric),
            examCard(examRound, prompt: "3/4 cup", answer: 180, unit: " mL", kind: .volume, direction: .imperialToMetric),
            examCard(examRound, prompt: "2 teaspoons", answer: 10, unit: " mL", kind: .volume, direction: .imperialToMetric),
            examCard(examRound, prompt: "480 mL", answer: 2, unit: " cups", kind: .volume, direction: .metricToImperial),
            examCard(examRound, prompt: "1/3 cup", answer: 80, unit: " mL", kind: .volume, direction: .imperialToMetric),
            examCard(examRound, prompt: "60 mL", answer: 1, unit: " quarter-cup", kind: .volume, direction: .metricToImperial),

            // Weight anchors
            examCard(examRound, prompt: "1 ounce (by weight)", answer: 30, unit: " g", kind: .weight, direction: .imperialToMetric),
            examCard(examRound, prompt: "1 pound", answer: 450, unit: " g", kind: .weight, direction: .imperialToMetric),
            examCard(examRound, prompt: "1 cup all-purpose flour", answer: 120, unit: " g", kind: .weight, direction: .imperialToMetric),
            examCard(examRound, prompt: "1 cup granulated sugar", answer: 200, unit: " g", kind: .weight, direction: .imperialToMetric),
            examCard(examRound, prompt: "1 stick butter", answer: 113, unit: " g", kind: .weight, direction: .imperialToMetric),
            examCard(examRound, prompt: "450 g", answer: 1, unit: " lb", kind: .weight, direction: .metricToImperial),

            // Boolean
            KitchenCard(
                roundIndex: examRound,
                kind: .booleanComparison,
                direction: .imperialToMetric,
                challengeType: .booleanChoice,
                prompt: "Does 1 cup of flour weigh the same as 1 cup of sugar?",
                correctAnswer: 0,
                answerUnit: "",
                label: "Different ingredients, different weights",
                examQuestionID: "exam-boolean-flour-sugar"
            ),

            // Oven temperatures
            examTemperatureCard(examRound, fahrenheit: 350, celsius: 175, direction: .imperialToMetric),
            examTemperatureCard(examRound, fahrenheit: 400, celsius: 200, direction: .metricToImperial, promptCelsius: 200),
            examTemperatureCard(examRound, fahrenheit: 425, celsius: 220, direction: .metricToImperial, promptCelsius: 220),
            examTemperatureCard(examRound, fahrenheit: 300, celsius: 150, direction: .metricToImperial, promptCelsius: 150),
            examTemperatureCard(examRound, fahrenheit: 375, celsius: 190, direction: .imperialToMetric),
            examTemperatureCard(examRound, fahrenheit: 450, celsius: 230, direction: .imperialToMetric),

            // Food safety — exact answers only
            examSafetyCard(examRound, prompt: "Chicken should reach what internal temperature?", fahrenheit: 165, celsius: 74),
            examSafetyCard(examRound, prompt: "Ground beef should reach what internal temperature?", fahrenheit: 160, celsius: 71),
            examSafetyCard(
                examRound,
                prompt: "Whole cuts of pork should reach what internal temperature (with rest time)?",
                fahrenheit: 145,
                celsius: 63
            ),
            examSafetyCard(examRound, prompt: "Leftovers and casseroles should reach what internal temperature?", fahrenheit: 165, celsius: 74),
            examSafetyCard(examRound, prompt: "Fish should reach what internal temperature?", fahrenheit: 145, celsius: 63),
            examSafetyCard(examRound, prompt: "Turkey should reach what internal temperature?", fahrenheit: 165, celsius: 74),

            // Pan and dish sizes
            examPanCard(
                examRound,
                prompt: "An American recipe calls for an 8 × 8 inch pan. What common metric size should you look for?",
                answerLabel: "20 × 20 cm"
            ),
            examPanCard(
                examRound,
                prompt: "An American recipe calls for a 9 × 13 inch casserole dish. What common metric size is closest?",
                answerLabel: "23 × 33 cm"
            ),
            examPanCard(
                examRound,
                prompt: "An American recipe calls for a 9 inch round cake pan. What metric cake tin is closest?",
                answerLabel: "23 cm round"
            ),
            examPanCard(
                examRound,
                prompt: "An American recipe calls for an 8 inch round cake pan. What metric cake tin is closest?",
                answerLabel: "20 cm round"
            ),
            examPanCard(
                examRound,
                prompt: "An American recipe calls for a 9 × 5 inch loaf pan. What metric loaf tin is closest?",
                answerLabel: "23 × 13 cm"
            ),
            examPanConceptCard(
                examRound,
                prompt: "True or false: pan-size conversions are always exact.",
                choiceLabels: ["True", "False"],
                correctIndex: 1,
                examID: "exam-pan-concept-exact"
            ),
            examPanConceptCard(
                examRound,
                prompt: "True or false: for cakes, pan area and depth can affect baking time and results.",
                choiceLabels: ["True", "False"],
                correctIndex: 0,
                examID: "exam-pan-concept-cake-area"
            ),
            examPanConceptCard(
                examRound,
                prompt: "If the substitute pan is much larger, what usually happens?",
                choiceLabels: [
                    "The food is thinner and may cook faster",
                    "The food is thicker and may cook slower",
                    "Nothing changes",
                    "The food will always overflow",
                ],
                correctIndex: 0,
                examID: "exam-pan-concept-larger"
            ),
            examPanConceptCard(
                examRound,
                prompt: "If the substitute pan is much smaller, what usually happens?",
                choiceLabels: [
                    "The food is thinner and may cook faster",
                    "The food is thicker, may cook slower, and may overflow",
                    "Nothing changes",
                    "The food will always underbake on top only",
                ],
                correctIndex: 1,
                examID: "exam-pan-concept-smaller"
            ),
        ]
    }()

    // MARK: - Builders

    private struct KitchenAnchorPair {
        let kind: KitchenCardKind
        let imperialPrompt: String
        let metricPrompt: String
        var metricPromptValue: Int? = nil
        let metricAnswer: Int
        let metricUnit: String
        var toleranceOverride: Int? = nil
        let reverseAnswer: Int
        let reverseUnit: String
        let label: String
    }

    private struct KitchenTemperatureAnchor {
        let fahrenheit: Int
        let celsius: Int
        let label: String
    }

    private struct KitchenSafetyAnchor {
        let fahrenheit: Int
        let celsius: Int
        let label: String
    }

    private static func pairedCards(roundIndex: Int, anchors: [KitchenAnchorPair]) -> [KitchenCard] {
        anchors.enumerated().flatMap { offset, anchor in
            let sliderType: KitchenChallengeType = offset.isMultiple(of: 2) ? .measurementSlider : .multipleChoice
            let mcType: KitchenChallengeType = offset.isMultiple(of: 2) ? .multipleChoice : .measurementSlider

            let imperialCard = KitchenCard(
                roundIndex: roundIndex,
                kind: anchor.kind,
                direction: .imperialToMetric,
                challengeType: sliderType,
                prompt: anchor.imperialPrompt,
                correctAnswer: anchor.metricAnswer,
                answerUnit: anchor.metricUnit,
                label: anchor.label,
                toleranceOverride: anchor.toleranceOverride
            )

            let metricCard = KitchenCard(
                roundIndex: roundIndex,
                kind: anchor.kind,
                direction: .metricToImperial,
                challengeType: mcType,
                prompt: anchor.metricPrompt,
                promptValue: anchor.metricPromptValue,
                correctAnswer: anchor.reverseAnswer,
                answerUnit: anchor.reverseUnit,
                label: anchor.label,
                toleranceOverride: anchor.toleranceOverride
            )

            return [imperialCard, metricCard]
        }
    }

    private static func pairedTemperatureCards(
        roundIndex: Int,
        anchors: [KitchenTemperatureAnchor],
        kind: KitchenCardKind
    ) -> [KitchenCard] {
        anchors.enumerated().flatMap { offset, anchor in
            let sliderType: KitchenChallengeType = offset.isMultiple(of: 2) ? .measurementSlider : .multipleChoice
            let mcType: KitchenChallengeType = offset.isMultiple(of: 2) ? .multipleChoice : .measurementSlider

            let fToC = KitchenCard(
                roundIndex: roundIndex,
                kind: kind,
                direction: .imperialToMetric,
                challengeType: sliderType,
                prompt: "\(anchor.fahrenheit)°F",
                promptValue: anchor.fahrenheit,
                promptUnit: "°F",
                correctAnswer: anchor.celsius,
                answerUnit: "°C",
                label: anchor.label
            )

            let cToF = KitchenCard(
                roundIndex: roundIndex,
                kind: kind,
                direction: .metricToImperial,
                challengeType: mcType,
                prompt: "\(anchor.celsius)°C",
                promptValue: anchor.celsius,
                promptUnit: "°C",
                correctAnswer: anchor.fahrenheit,
                answerUnit: "°F",
                label: anchor.label
            )

            return [fToC, cToF]
        }
    }

    private static func foodSafetyCards(roundIndex: Int, anchors: [KitchenSafetyAnchor]) -> [KitchenCard] {
        anchors.flatMap { anchor in
            // Food safety always uses multiple choice — exact values, no dangerously low tolerance.
            let fahrenheitCard = KitchenCard(
                roundIndex: roundIndex,
                kind: .foodSafetyTemperature,
                direction: .imperialToMetric,
                challengeType: .multipleChoice,
                prompt: anchor.label,
                correctAnswer: anchor.fahrenheit,
                answerUnit: "°F",
                label: "USDA minimum internal temperature",
                requiresExactAnswer: true,
                alternateExactAnswer: anchor.celsius
            )

            let celsiusCard = KitchenCard(
                roundIndex: roundIndex,
                kind: .foodSafetyTemperature,
                direction: .metricToImperial,
                challengeType: .multipleChoice,
                prompt: anchor.label,
                correctAnswer: anchor.celsius,
                answerUnit: "°C",
                label: "USDA minimum internal temperature",
                requiresExactAnswer: true,
                alternateExactAnswer: anchor.fahrenheit
            )

            return [fahrenheitCard, celsiusCard]
        }
    }

    private static func examCard(
        _ roundIndex: Int,
        prompt: String,
        promptValue: Int? = nil,
        answer: Int,
        unit: String,
        kind: KitchenCardKind,
        direction: KitchenConversionDirection,
        label: String? = nil
    ) -> KitchenCard {
        KitchenCard(
            roundIndex: roundIndex,
            kind: kind,
            direction: direction,
            challengeType: .multipleChoice,
            prompt: prompt,
            promptValue: promptValue,
            correctAnswer: answer,
            answerUnit: unit,
            label: label,
            examQuestionID: "exam-\(prompt)-\(direction.rawValue)-\(answer)"
        )
    }

    private static func examTemperatureCard(
        _ roundIndex: Int,
        fahrenheit: Int,
        celsius: Int,
        direction: KitchenConversionDirection,
        promptCelsius: Int? = nil
    ) -> KitchenCard {
        switch direction {
        case .imperialToMetric:
            return KitchenCard(
                roundIndex: roundIndex,
                kind: .ovenTemperature,
                direction: direction,
                challengeType: .multipleChoice,
                prompt: "\(fahrenheit)°F",
                promptValue: fahrenheit,
                promptUnit: "°F",
                correctAnswer: celsius,
                answerUnit: "°C",
                examQuestionID: "exam-oven-\(fahrenheit)-toC"
            )
        case .metricToImperial:
            let c = promptCelsius ?? celsius
            return KitchenCard(
                roundIndex: roundIndex,
                kind: .ovenTemperature,
                direction: direction,
                challengeType: .multipleChoice,
                prompt: "\(c)°C",
                promptValue: c,
                promptUnit: "°C",
                correctAnswer: fahrenheit,
                answerUnit: "°F",
                label: "Which Fahrenheit oven setting is closest?",
                examQuestionID: "exam-oven-\(c)-toF"
            )
        }
    }

    static func stablePromptID(_ prompt: String) -> String {
        prompt
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "/", with: "-")
    }

    private static func examSafetyCard(
        _ roundIndex: Int,
        prompt: String,
        fahrenheit: Int,
        celsius: Int
    ) -> KitchenCard {
        KitchenCard(
            roundIndex: roundIndex,
            kind: .foodSafetyTemperature,
            direction: .imperialToMetric,
            challengeType: .multipleChoice,
            prompt: prompt,
            correctAnswer: fahrenheit,
            answerUnit: "°F",
            requiresExactAnswer: true,
            alternateExactAnswer: celsius,
            examQuestionID: "exam-safety-\(fahrenheit)-\(stablePromptID(prompt))"
        )
    }
}
