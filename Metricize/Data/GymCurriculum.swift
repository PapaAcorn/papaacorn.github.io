//
//  GymCurriculum.swift
//  Metricize
//

import Foundation

enum GymCurriculum {
    static let rounds: [GymRound] = [
        GymRound(index: 0, title: "Body Weight", kind: .learning, cards: round1Cards),
        GymRound(index: 1, title: "Dumbbells and Light Gym Weights", kind: .learning, cards: round2Cards),
        GymRound(index: 2, title: "Heavy Weights, Barbells, and Machines", kind: .learning, cards: round3Cards),
        GymRound(index: 3, title: "Barbell Plates and Familiar Gym Anchors", kind: .learning, cards: round4Cards),
        GymRound(index: 4, title: "Treadmills, Bikes, and Cardio Speeds", kind: .learning, cards: round5Cards),
        GymRound(
            index: GymGameConstants.finalExamRoundIndex,
            title: "Final Exam",
            kind: .finalExam,
            cards: []
        ),
    ]

    // MARK: - Round 1: Body Weight

    private static let round1Cards: [GymCard] = pairedCards(
        roundIndex: 0,
        kind: .bodyWeight,
        anchors: [
            weightAnchor(metric: "50 kg", imperial: "110 lb", label: "Light adult reference"),
            weightAnchor(metric: "55 kg", imperial: "120 lb", label: "Common fitness-app weight"),
            weightAnchor(metric: "60 kg", imperial: "130 lb", label: "Lean adult reference"),
            weightAnchor(metric: "65 kg", imperial: "145 lb", label: "Mid-range body weight"),
            weightAnchor(metric: "70 kg", imperial: "155 lb", label: "Common gym profile weight"),
            weightAnchor(metric: "75 kg", imperial: "165 lb", label: "Athletic build reference"),
            weightAnchor(
                metric: "80 kg",
                imperial: "175 lb",
                metricPrompt: "A scale says 80 kg. About how much is that in pounds?",
                label: "Hotel or gym scale reading"
            ),
            weightAnchor(metric: "85 kg", imperial: "185 lb", label: "Strength-training body weight"),
            weightAnchor(metric: "90 kg", imperial: "200 lb", label: "Round-number body weight"),
            weightAnchor(
                metric: "95 kg",
                imperial: "210 lb",
                metricPrompt: "A fitness app lists body weight as 95 kg. About how much is that?",
                label: "Fitness app listing"
            ),
            weightAnchor(metric: "100 kg", imperial: "220 lb", label: "Century kilogram anchor"),
            weightAnchor(metric: "110 kg", imperial: "240 lb", label: "Heavy adult reference"),
            weightAnchor(metric: "120 kg", imperial: "265 lb", label: "Large adult reference"),
            weightAnchor(metric: "135 kg", imperial: "300 lb", label: "Very heavy adult reference"),
            weightAnchor(metric: "150 kg", imperial: "330 lb", label: "Maximum common scale reading"),
        ]
    )

    // MARK: - Round 2: Dumbbells and Light Gym Weights

    private static let round2Cards: [GymCard] = pairedCards(
        roundIndex: 1,
        kind: .lightWeight,
        anchors: [
            weightAnchor(metric: "1 kg", imperial: "2 lb", label: "Tiny dumbbell"),
            weightAnchor(metric: "2 kg", imperial: "4 lb", label: "Warmup dumbbell"),
            weightAnchor(metric: "3 kg", imperial: "7 lb", label: "Light isolation weight"),
            weightAnchor(metric: "4 kg", imperial: "9 lb", label: "Small accessory weight"),
            weightAnchor(metric: "5 kg", imperial: "11 lb", label: "Common light dumbbell"),
            weightAnchor(metric: "6 kg", imperial: "13 lb", label: "Light rack weight"),
            weightAnchor(metric: "8 kg", imperial: "18 lb", label: "Moderate warmup"),
            weightAnchor(
                metric: "10 kg",
                imperial: "22 lb",
                metricPrompt: "A dumbbell is labeled 10 kg. About how heavy is that in pounds?",
                label: "Standard metric dumbbell"
            ),
            weightAnchor(metric: "12 kg", imperial: "26 lb", label: "Moderate dumbbell"),
            weightAnchor(metric: "14 kg", imperial: "30 lb", label: "Heavier isolation dumbbell"),
            weightAnchor(metric: "16 kg", imperial: "35 lb", label: "Common kettlebell size"),
            weightAnchor(
                metric: "18 kg",
                imperial: "40 lb",
                metricPrompt: "A kettlebell is 18 kg. About how much is that?",
                label: "Kettlebell reference"
            ),
            weightAnchor(metric: "20 kg", imperial: "44 lb", label: "Heavy single dumbbell"),
            weightAnchor(metric: "22 kg", imperial: "50 lb", label: "Top rack dumbbell for many gyms"),
            weightAnchor(metric: "24 kg", imperial: "53 lb", label: "Advanced dumbbell weight"),
        ]
    )

    // MARK: - Round 3: Heavy Weights, Barbells, and Machines

    private static let round3Cards: [GymCard] = pairedCards(
        roundIndex: 2,
        kind: .heavyWeight,
        anchors: [
            weightAnchor(metric: "25 kg", imperial: "55 lb", label: "Light barbell plate pair"),
            weightAnchor(metric: "30 kg", imperial: "65 lb", label: "Machine stack increment"),
            weightAnchor(metric: "35 kg", imperial: "75 lb", label: "Moderate machine weight"),
            weightAnchor(metric: "40 kg", imperial: "90 lb", label: "Leg press warmup"),
            weightAnchor(metric: "45 kg", imperial: "100 lb", label: "Round imperial anchor"),
            weightAnchor(metric: "50 kg", imperial: "110 lb", label: "Common machine setting"),
            weightAnchor(
                metric: "60 kg",
                imperial: "135 lb",
                metricPrompt: "A machine stack is set to 60 kg. About how much is that in pounds?",
                label: "Cable or machine stack"
            ),
            weightAnchor(metric: "70 kg", imperial: "155 lb", label: "Heavy machine weight"),
            weightAnchor(metric: "80 kg", imperial: "175 lb", label: "Strong lifter working weight"),
            weightAnchor(metric: "90 kg", imperial: "200 lb", label: "Heavy squat or press"),
            weightAnchor(
                metric: "100 kg",
                imperial: "220 lb",
                metricPrompt: "A barbell is loaded to 100 kg. About how much is that?",
                label: "Loaded barbell reference"
            ),
            weightAnchor(metric: "120 kg", imperial: "265 lb", label: "Advanced barbell load"),
            weightAnchor(metric: "140 kg", imperial: "310 lb", label: "Heavy leg press"),
            weightAnchor(metric: "160 kg", imperial: "350 lb", label: "Elite machine weight"),
            weightAnchor(metric: "180 kg", imperial: "400 lb", label: "Maximum common gym load"),
        ]
    )

    // MARK: - Round 4: Barbell Plates and Familiar Gym Anchors

    private static let round4Cards: [GymCard] = pairedCards(
        roundIndex: 3,
        kind: .plateAndBarbell,
        anchors: [
            plateAnchor(
                metric: "5 kg plate",
                imperial: "11 lb",
                metricPrompt: "A plate is labeled 5 kg. About how much is that in pounds?",
                imperialPrompt: "An 11 lb plate is about how many kilograms?",
                label: "Smallest common metric plate"
            ),
            plateAnchor(metric: "10 kg plate", imperial: "22 lb", label: "Small metric plate"),
            plateAnchor(metric: "15 kg plate", imperial: "33 lb", label: "Medium metric plate"),
            plateAnchor(
                metric: "20 kg plate",
                imperial: "44 lb",
                metricPrompt: "A plate is labeled 20 kg. About how much is that in pounds?",
                label: "Standard large metric plate"
            ),
            plateAnchor(metric: "25 kg plate", imperial: "55 lb", label: "Largest common metric plate"),
            plateAnchor(
                metric: "20 kg Olympic bar",
                imperial: "45 lb",
                metricPrompt: "A standard Olympic bar weighs 20 kg. About how much is that in pounds?",
                imperialPrompt: "A 45 lb Olympic bar is about how many kilograms?",
                label: "Standard Olympic bar — not an exact U.S. match"
            ),
            totalLoadAnchor(
                metric: "30 kg total",
                imperial: "65 lb",
                metricPrompt: "A barbell totals 30 kg (bar plus small plates). About how much is that in pounds?",
                imperialPrompt: "A barbell totals about 65 lb. About how much is that in kilograms?",
                label: "Bar plus small plates"
            ),
            totalLoadAnchor(metric: "40 kg total", imperial: "90 lb", label: "Light working barbell"),
            totalLoadAnchor(
                metric: "60 kg total",
                imperial: "135 lb",
                metricPrompt: "A barbell is loaded to 60 kg total. What familiar U.S. gym weight is that close to?",
                label: "Common working weight"
            ),
            totalLoadAnchor(metric: "80 kg total", imperial: "175 lb", label: "Intermediate barbell load"),
            totalLoadAnchor(metric: "100 kg total", imperial: "220 lb", label: "Strong barbell load"),
            totalLoadAnchor(metric: "120 kg total", imperial: "265 lb", label: "Advanced barbell load"),
        ]
    )

    // MARK: - Round 5: Treadmills, Bikes, and Cardio Speeds

    private static let round5Cards: [GymCard] = pairedCards(
        roundIndex: 4,
        kind: .cardioSpeed,
        anchors: [
            speedAnchor(metric: "3 km/h", imperial: "2 mph", label: "Very slow walk"),
            speedAnchor(metric: "5 km/h", imperial: "3 mph", label: "Easy treadmill walk"),
            speedAnchor(metric: "6 km/h", imperial: "4 mph", label: "Brisk walk"),
            speedAnchor(metric: "8 km/h", imperial: "5 mph", label: "Power walk"),
            speedAnchor(
                metric: "10 km/h",
                imperial: "6 mph",
                metricPrompt: "A treadmill is set to 10 km/h. About how fast is that in mph?",
                label: "Jogging pace"
            ),
            speedAnchor(metric: "11 km/h", imperial: "7 mph", label: "Light run"),
            speedAnchor(metric: "13 km/h", imperial: "8 mph", label: "Steady run"),
            speedAnchor(metric: "14.5 km/h", imperial: "9 mph", label: "Faster run"),
            speedAnchor(metric: "16 km/h", imperial: "10 mph", label: "Strong run"),
            speedAnchor(metric: "20 km/h", imperial: "12 mph", label: "Fast treadmill run"),
            speedAnchor(
                metric: "24 km/h",
                imperial: "15 mph",
                metricPrompt: "An exercise bike shows 24 km/h. About how fast is that?",
                label: "Exercise bike sprint"
            ),
            speedAnchor(metric: "30 km/h", imperial: "19 mph", label: "Very fast bike or sprint"),
        ]
    )

    static let roundIntroTips: [Int: [String]] = [
        0: [
            "Body weight is usually measured in kilograms outside the United States. A useful shortcut is that 1 kg is about 2.2 pounds. This round teaches common body-weight landmarks so users can recognize weights quickly.",
            "These are practical fitness approximations. Some values are rounded so they are easier to remember and useful during real workouts.",
        ],
        1: [
            "Dumbbells and kettlebells in metric gyms are usually labeled in kilograms. A 10 kg dumbbell is about 22 pounds, and a 20 kg dumbbell is about 44 pounds. This round focuses on lighter and moderate weights used for dumbbells, accessories, warmups, and isolation exercises.",
            "These are practical fitness approximations. Some values are rounded so they are easier to remember and useful during real workouts.",
        ],
        2: [
            "Heavier gym weights are still usually labeled in kilograms in metric countries. For fast estimates, doubling the kilogram number and adding a little more gets you close. For example, 100 kg is about 220 pounds.",
            "These are practical fitness approximations. Some values are rounded so they are easier to remember and useful during real workouts.",
        ],
        3: [
            "Metric gyms often use plates like 5 kg, 10 kg, 15 kg, 20 kg, and 25 kg. These do not match U.S. plates exactly, but they are close enough to build useful mental anchors. A standard Olympic bar is usually 20 kg, which is about 45 pounds.",
            "These are practical fitness approximations. Some values are rounded so they are easier to remember and useful during real workouts.",
        ],
        4: [
            "Cardio machines in metric countries often show speed in kilometers per hour. A useful shortcut is that 10 km/h is about 6 mph. This round teaches common walking, jogging, running, and bike-speed references.",
            "These are practical fitness approximations. Some values are rounded so they are easier to remember and useful during real workouts.",
        ],
    ]

    static let finalExamIntroTips: [String] = [
        "You have learned body-weight references, dumbbell weights, heavy gym weights, barbell plates, and cardio-machine speeds. This final exam mixes everything together. Score 80% or higher to complete the module.",
        "These are practical fitness approximations. Some values are rounded so they are easier to remember and useful during real workouts.",
    ]

    static func tips(forRound roundIndex: Int) -> [String] {
        if roundIndex == GymGameConstants.finalExamRoundIndex {
            return finalExamIntroTips
        }
        return roundIntroTips[roundIndex] ?? ["Practice makes approximation instinctive."]
    }

    static func roundTitle(for roundIndex: Int) -> String {
        rounds.first(where: { $0.index == roundIndex })?.title ?? "Round \(roundIndex + 1)"
    }

    static var learningRounds: [GymRound] {
        rounds.filter { $0.kind == .learning }
    }

    static var allCards: [GymCard] {
        learningRounds.flatMap(\.cards)
    }

    static func cards(forRound index: Int) -> [GymCard] {
        rounds.first(where: { $0.index == index })?.cards ?? []
    }

    static func cards(forRound roundIndex: Int, subRoundIndex: Int) -> [GymCard] {
        guard let round = rounds.first(where: { $0.index == roundIndex }), round.kind == .learning else {
            return []
        }
        let all = round.cards
        switch subRoundIndex {
        case 0:
            return all.filter { $0.direction == .metricToImperial }
        case 1:
            return all.filter { $0.direction == .imperialToMetric }
        case GymGameConstants.mixedSubRoundIndex:
            return all
        default:
            return all
        }
    }

    static func subRoundLabel(majorRoundIndex: Int, subRoundIndex: Int) -> String {
        if majorRoundIndex == GymGameConstants.finalExamRoundIndex {
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

    static func batchReviewItems(for cards: [GymCard]) -> [ConversionReviewItem] {
        cards.map { card in
            ConversionReviewItem(
                id: card.id,
                source: reviewSource(for: card),
                target: reviewTarget(for: card)
            )
        }
    }

    static func reviewSource(for card: GymCard) -> String {
        if let promptValue = card.promptValue, let promptUnit = card.promptUnit {
            return "\(promptValue)\(promptUnit)"
        }
        return sourceDisplay(for: card)
    }

    static func reviewTarget(for card: GymCard) -> String {
        "≈ \(card.answerLabel)"
    }

    static func generateFinalExamQuestions(
        count: Int = GymGameConstants.examQuestionCount
    ) -> [GymCard] {
        var questions: [GymCard] = []
        var usedIDs = Set<String>()

        for roundIndex in 0..<GymGameConstants.learningRoundCount {
            let roundCards = cards(forRound: roundIndex)
            let shuffled = roundCards.shuffled()
            var added = 0
            for template in shuffled where added < GymGameConstants.examQuestionsPerRound {
                let examID = "exam-r\(roundIndex)-\(template.id)"
                guard !usedIDs.contains(examID) else { continue }
                usedIDs.insert(examID)
                questions.append(examCard(from: template, examQuestionID: examID))
                added += 1
            }
        }

        if questions.count < count {
            let extras = allCards.shuffled()
            for template in extras where questions.count < count {
                let examID = "exam-extra-\(template.id)-\(questions.count)"
                guard !usedIDs.contains(examID) else { continue }
                usedIDs.insert(examID)
                questions.append(examCard(from: template, examQuestionID: examID))
            }
        }

        return Array(questions.prefix(count)).shuffled()
    }

    // MARK: - Builders

    private struct GymAnchorPair {
        let metricSource: String
        let imperialSource: String
        let metricToImperialPrompt: String
        let imperialToMetricPrompt: String
        let imperialAnswer: String
        let metricAnswer: String
        let label: String
        let metricPromptValue: Int?
        let metricPromptUnit: String?
        let imperialPromptValue: Int?
        let imperialPromptUnit: String?
    }

    private static func pairedCards(
        roundIndex: Int,
        kind: GymCardKind,
        anchors: [GymAnchorPair]
    ) -> [GymCard] {
        anchors.flatMap { anchor in
            let metricCard = GymCard(
                roundIndex: roundIndex,
                kind: kind,
                direction: .metricToImperial,
                prompt: anchor.metricToImperialPrompt,
                promptValue: anchor.metricPromptValue,
                promptUnit: anchor.metricPromptUnit,
                label: anchor.label,
                answerLabel: anchor.imperialAnswer
            )
            let imperialCard = GymCard(
                roundIndex: roundIndex,
                kind: kind,
                direction: .imperialToMetric,
                prompt: anchor.imperialToMetricPrompt,
                promptValue: anchor.imperialPromptValue,
                promptUnit: anchor.imperialPromptUnit,
                label: anchor.label,
                answerLabel: anchor.metricAnswer
            )
            return [metricCard, imperialCard]
        }
    }

    private static func weightAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        imperialPrompt: String? = nil,
        label: String
    ) -> GymAnchorPair {
        genericAnchor(
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? promptForMetricWeight(metric),
            imperialPrompt: imperialPrompt ?? promptForImperialWeight(imperial),
            label: label
        )
    }

    private static func plateAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        imperialPrompt: String? = nil,
        label: String
    ) -> GymAnchorPair {
        genericAnchor(
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A plate is labeled \(metric.replacingOccurrences(of: " plate", with: "")). About how much is that in pounds?",
            imperialPrompt: imperialPrompt ?? promptForImperialWeight(imperial),
            label: label
        )
    }

    private static func totalLoadAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        imperialPrompt: String? = nil,
        label: String
    ) -> GymAnchorPair {
        genericAnchor(
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A barbell totals \(metric.replacingOccurrences(of: " total", with: "")). About how much is that in pounds?",
            imperialPrompt: imperialPrompt ?? "A barbell totals about \(imperial). About how much is that in kilograms?",
            label: label
        )
    }

    private static func speedAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        imperialPrompt: String? = nil,
        label: String
    ) -> GymAnchorPair {
        genericAnchor(
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A treadmill is set to \(metric). About how fast is that in mph?",
            imperialPrompt: imperialPrompt ?? "A treadmill is set to \(imperial). About how fast is that in km/h?",
            label: label
        )
    }

    private static func promptForMetricWeight(_ metric: String) -> String {
        if metric.contains("total") || metric.contains("bar") || metric.contains("plate") {
            return "You see \(metric). About how much is that in pounds?"
        }
        return "You see \(metric). About how much is that in pounds?"
    }

    private static func promptForImperialWeight(_ imperial: String) -> String {
        "You're used to \(imperial). About how much is that in kilograms?"
    }

    private static func genericAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String,
        imperialPrompt: String,
        label: String
    ) -> GymAnchorPair {
        GymAnchorPair(
            metricSource: metric,
            imperialSource: imperial,
            metricToImperialPrompt: metricPrompt,
            imperialToMetricPrompt: imperialPrompt,
            imperialAnswer: imperial,
            metricAnswer: metric,
            label: label,
            metricPromptValue: parseLeadingNumber(from: metric),
            metricPromptUnit: parseUnitSuffix(from: metric),
            imperialPromptValue: parseLeadingNumber(from: imperial),
            imperialPromptUnit: parseUnitSuffix(from: imperial)
        )
    }

    private static func sourceDisplay(for card: GymCard) -> String {
        switch card.direction {
        case .metricToImperial:
            return extractMetricPhrase(from: card.prompt) ?? card.prompt
        case .imperialToMetric:
            return extractImperialPhrase(from: card.prompt) ?? card.prompt
        }
    }

    private static func extractMetricPhrase(from prompt: String) -> String? {
        let patterns = [
            #"(\d[\d.]*\s*(?:kg/h|kg|km/h))"#,
        ]
        for pattern in patterns {
            if let match = prompt.range(of: pattern, options: .regularExpression) {
                return String(prompt[match])
            }
        }
        return nil
    }

    private static func extractImperialPhrase(from prompt: String) -> String? {
        let patterns = [
            #"(\d[\d.]*\s*(?:mph|lb))"#,
        ]
        for pattern in patterns {
            if let match = prompt.range(of: pattern, options: .regularExpression) {
                return String(prompt[match])
            }
        }
        return nil
    }

    private static func parseLeadingNumber(from text: String) -> Int? {
        let cleaned = text.replacingOccurrences(of: ",", with: "")
        let digits = cleaned.prefix { $0.isNumber || $0 == "." }
        if digits.contains(".") {
            if let value = Double(digits) {
                return value == floor(value) ? Int(value) : nil
            }
            return nil
        }
        return Int(digits)
    }

    private static func parseUnitSuffix(from text: String) -> String? {
        if text.contains("km/h") { return " km/h" }
        if text.hasSuffix(" kg") || text.hasSuffix("kg") { return " kg" }
        if text.contains("mph") { return " mph" }
        if text.contains("lb") { return " lb" }
        return nil
    }

    private static func examCard(from template: GymCard, examQuestionID: String) -> GymCard {
        GymCard(
            roundIndex: GymGameConstants.finalExamRoundIndex,
            kind: template.kind,
            direction: template.direction,
            prompt: template.prompt,
            promptValue: template.promptValue,
            promptUnit: template.promptUnit,
            label: template.label,
            answerLabel: template.answerLabel,
            examQuestionID: examQuestionID
        )
    }
}
