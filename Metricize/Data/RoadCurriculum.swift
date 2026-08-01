//
//  RoadCurriculum.swift
//  Metricize
//

import Foundation

enum RoadCurriculum {
    static let rounds: [RoadRound] = [
        RoadRound(index: 0, title: "Road Speeds", kind: .learning, cards: round1Cards),
        RoadRound(index: 1, title: "Short Warning Distances", kind: .learning, cards: round2Cards),
        RoadRound(index: 2, title: "Walking and Nearby Travel Distances", kind: .learning, cards: round3Cards),
        RoadRound(index: 3, title: "Driving Distances", kind: .learning, cards: round4Cards),
        RoadRound(index: 4, title: "Travel Time Feel", kind: .learning, cards: round5Cards),
        RoadRound(
            index: RoadGameConstants.finalExamRoundIndex,
            title: "Final Exam",
            kind: .finalExam,
            cards: []
        ),
    ]

    // MARK: - Round 1: Road Speeds

    private static let round1Cards: [RoadCard] = pairedCards(
        roundIndex: 0,
        kind: .speed,
        anchors: [
            speedAnchor(metric: "10 km/h", imperial: "6 mph", label: "School zone or parking lot"),
            speedAnchor(metric: "20 km/h", imperial: "12 mph", label: "Residential side street"),
            speedAnchor(metric: "30 km/h", imperial: "20 mph", label: "Quiet neighborhood"),
            speedAnchor(metric: "40 km/h", imperial: "25 mph", label: "Urban side road"),
            speedAnchor(
                metric: "50 km/h",
                imperial: "30 mph",
                metricPrompt: "A road sign says 50 km/h. About how fast is that in mph?",
                label: "Common urban speed limit"
            ),
            speedAnchor(metric: "60 km/h", imperial: "35 mph", label: "Suburban arterial"),
            speedAnchor(metric: "70 km/h", imperial: "45 mph", label: "Open country road"),
            speedAnchor(metric: "80 km/h", imperial: "50 mph", label: "Rural highway"),
            speedAnchor(metric: "90 km/h", imperial: "55 mph", label: "Dual carriageway"),
            speedAnchor(metric: "100 km/h", imperial: "60 mph", label: "Motorway minimum"),
            speedAnchor(metric: "110 km/h", imperial: "70 mph", label: "Fast motorway"),
            speedAnchor(
                metric: "120 km/h",
                imperial: "75 mph",
                metricPrompt: "A motorway sign says 120 km/h. About how fast is that in mph?",
                label: "Common motorway limit"
            ),
            speedAnchor(metric: "130 km/h", imperial: "80 mph", label: "High-speed motorway"),
        ]
    )

    // MARK: - Round 2: Short Warning Distances

    private static let round2Cards: [RoadCard] = pairedCards(
        roundIndex: 1,
        kind: .shortDistance,
        anchors: [
            shortDistanceAnchor(metric: "25 m", imperial: "80 ft", label: "Very close warning"),
            shortDistanceAnchor(metric: "50 m", imperial: "165 ft", label: "Immediate hazard"),
            shortDistanceAnchor(metric: "75 m", imperial: "250 ft", label: "Upcoming turn"),
            shortDistanceAnchor(
                metric: "100 m",
                imperial: "330 ft",
                metricPrompt: "A sign says road works in 100 m. About how far ahead is that?",
                label: "Construction warning"
            ),
            shortDistanceAnchor(metric: "150 m", imperial: "500 ft", label: "Speed camera ahead"),
            shortDistanceAnchor(metric: "200 m", imperial: "650 ft", label: "Exit or junction"),
            shortDistanceAnchor(metric: "250 m", imperial: "820 ft", label: "Parking entrance"),
            shortDistanceAnchor(
                metric: "300 m",
                imperial: "1,000 ft",
                metricPrompt: "Your navigation app says turn left in 300 m. About how far is that?",
                label: "Navigation prompt"
            ),
            shortDistanceAnchor(metric: "400 m", imperial: "1/4 mile", label: "Quarter-mile marker"),
            shortDistanceAnchor(metric: "500 m", imperial: "1/3 mile", label: "Third-mile marker"),
        ]
    )

    // MARK: - Round 3: Walking and Nearby Travel Distances

    private static let round3Cards: [RoadCard] = pairedCards(
        roundIndex: 2,
        kind: .walkingDistance,
        anchors: [
            walkingAnchor(metric: "600 m", imperial: "0.4 miles", label: "Short walk"),
            walkingAnchor(metric: "750 m", imperial: "0.5 miles", label: "Ten-minute walk"),
            walkingAnchor(
                metric: "1 km",
                imperial: "0.6 miles",
                metricPrompt: "A museum is 1 km away. About how far is that in miles?",
                label: "Nearby attraction"
            ),
            walkingAnchor(metric: "1.2 km", imperial: "0.75 miles", label: "Comfortable walk"),
            walkingAnchor(
                metric: "1.5 km",
                imperial: "1 mile",
                metricPrompt: "The hotel is 1.5 km away. About how far is that?",
                label: "Walkable destination"
            ),
            walkingAnchor(metric: "2 km", imperial: "1.25 miles", label: "Longer city walk"),
            walkingAnchor(metric: "2.5 km", imperial: "1.5 miles", label: "Transit stop distance"),
            walkingAnchor(metric: "3 km", imperial: "2 miles", label: "Park to downtown"),
            walkingAnchor(metric: "4 km", imperial: "2.5 miles", label: "Across town"),
            walkingAnchor(metric: "5 km", imperial: "3 miles", label: "Edge of walking range"),
        ]
    )

    // MARK: - Round 4: Driving Distances

    private static let round4Cards: [RoadCard] = pairedCards(
        roundIndex: 3,
        kind: .drivingDistance,
        anchors: [
            drivingAnchor(metric: "10 km", imperial: "6 miles", label: "Short hop"),
            drivingAnchor(metric: "15 km", imperial: "9 miles", label: "Nearby town"),
            drivingAnchor(metric: "20 km", imperial: "12 miles", label: "Suburban drive"),
            drivingAnchor(metric: "25 km", imperial: "15 miles", label: "Regional trip"),
            drivingAnchor(metric: "30 km", imperial: "20 miles", label: "Commute distance"),
            drivingAnchor(metric: "40 km", imperial: "25 miles", label: "Cross-county"),
            drivingAnchor(
                metric: "50 km",
                imperial: "30 miles",
                metricPrompt: "A sign says the next city is 50 km away. About how far is that in miles?",
                label: "Intercity sign"
            ),
            drivingAnchor(metric: "75 km", imperial: "45 miles", label: "Half-day drive start"),
            drivingAnchor(metric: "100 km", imperial: "60 miles", label: "Hour on motorway"),
            drivingAnchor(metric: "150 km", imperial: "90 miles", label: "Long regional drive"),
            drivingAnchor(
                metric: "200 km",
                imperial: "125 miles",
                metricPrompt: "Your route says 200 km remaining. About how many miles is that?",
                label: "Road trip leg"
            ),
            drivingAnchor(metric: "300 km", imperial: "185 miles", label: "Major intercity distance"),
        ]
    )

    // MARK: - Round 5: Travel Time Feel

    private static let round5Cards: [RoadCard] = {
        let anchors: [RoadConceptAnchor] = [
            RoadConceptAnchor(
                metricPrompt: "About 10 km at city speeds feels like what kind of drive?",
                imperialPrompt: "A short local drive is roughly how far in kilometers?",
                metricAnswer: "A short local drive",
                imperialAnswer: "About 10 km",
                label: "City driving feel"
            ),
            RoadConceptAnchor(
                metricPrompt: "About 30 km is roughly how many miles?",
                imperialPrompt: "About 20 miles is roughly how many kilometers?",
                metricAnswer: "About 20 miles",
                imperialAnswer: "About 30 km",
                label: "Regional distance anchor"
            ),
            RoadConceptAnchor(
                metricPrompt: "About 50 km is roughly how many miles?",
                imperialPrompt: "About 30 miles is roughly how many kilometers?",
                metricAnswer: "About 30 miles",
                imperialAnswer: "About 50 km",
                label: "Half-hour motorway distance"
            ),
            RoadConceptAnchor(
                metricPrompt: "If a route is 100 km, what is the rough mile equivalent?",
                imperialPrompt: "About 60 miles is roughly how many kilometers?",
                metricAnswer: "About 60 miles",
                imperialAnswer: "About 100 km",
                label: "Hour on the road"
            ),
            RoadConceptAnchor(
                metricPrompt: "100 km/h is about how fast in mph?",
                imperialPrompt: "60 mph is about how fast in km/h?",
                metricAnswer: "60 mph",
                imperialAnswer: "100 km/h",
                label: "Highway speed anchor"
            ),
            RoadConceptAnchor(
                metricPrompt: "120 km/h is about how fast in mph?",
                imperialPrompt: "75 mph is about how fast in km/h?",
                metricAnswer: "75 mph",
                imperialAnswer: "120 km/h",
                label: "Fast motorway speed"
            ),
            RoadConceptAnchor(
                metricPrompt: "At about 100 km/h, how far do you travel in 30 minutes?",
                imperialPrompt: "30 minutes at highway speed in miles is about how many kilometers?",
                metricAnswer: "About 50 km",
                imperialAnswer: "About 50 km",
                label: "Half hour at motorway speed"
            ),
            RoadConceptAnchor(
                metricPrompt: "At about 100 km/h, how far do you travel in 1 hour?",
                imperialPrompt: "1 hour at highway speed in miles is about how many kilometers?",
                metricAnswer: "About 100 km",
                imperialAnswer: "About 100 km",
                label: "One hour at motorway speed"
            ),
            RoadConceptAnchor(
                metricPrompt: "At about 60 mph, how far is that in kilometers after 30 minutes?",
                imperialPrompt: "30 minutes at 60 mph is about how far in kilometers?",
                metricAnswer: "About 50 km",
                imperialAnswer: "About 50 km",
                label: "Half hour at 60 mph"
            ),
            RoadConceptAnchor(
                metricPrompt: "At about 60 mph, how far is that in kilometers after 1 hour?",
                imperialPrompt: "1 hour at 60 mph is about how far in kilometers?",
                metricAnswer: "About 100 km",
                imperialAnswer: "About 100 km",
                label: "One hour at 60 mph"
            ),
        ]
        return conceptCards(roundIndex: 4, anchors: anchors)
    }()

    static let roundIntroTips: [Int: [String]] = [
        0: [
            "Most countries post speed limits in kilometers per hour. You do not need exact math while driving. It is more useful to recognize the common speeds and know roughly how fast they feel in miles per hour.",
            "These are practical travel approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
        ],
        1: [
            "Road signs often warn you about something coming up soon: a turn, a crossing, a speed camera, road work, a parking entrance, or a hazard. These short distances are usually shown in meters.",
            "These are practical travel approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
        ],
        2: [
            "Maps and signs often describe nearby destinations in meters or kilometers. These distances are especially useful when walking through cities, finding parking, or deciding whether something is close enough to reach on foot.",
            "These are practical travel approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
        ],
        3: [
            "Longer driving distances are usually shown in kilometers. A useful shortcut is that 1 kilometer is about 0.6 miles. These conversions help you quickly understand how far away a town, attraction, border, airport, or fuel stop is.",
            "These are practical travel approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
        ],
        4: [
            "Drivers and travelers often need a rough sense of how long a distance will take. These examples are not exact because traffic, road type, stops, and speed limits matter. They are useful mental anchors.",
            "These are practical travel approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
        ],
    ]

    static let finalExamIntroTips: [String] = [
        "You have learned the road speeds, warning distances, walking distances, driving distances, and travel-time anchors most likely to help while traveling in metric countries. This final exam mixes everything together. Score 80% or higher to complete the module.",
        "These are practical travel approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
    ]

    static func tips(forRound roundIndex: Int) -> [String] {
        if roundIndex == RoadGameConstants.finalExamRoundIndex {
            return finalExamIntroTips
        }
        return roundIntroTips[roundIndex] ?? ["Practice makes approximation instinctive."]
    }

    static func roundTitle(for roundIndex: Int) -> String {
        rounds.first(where: { $0.index == roundIndex })?.title ?? "Round \(roundIndex + 1)"
    }

    static var learningRounds: [RoadRound] {
        rounds.filter { $0.kind == .learning }
    }

    static var allCards: [RoadCard] {
        learningRounds.flatMap(\.cards)
    }

    static func cards(forRound index: Int) -> [RoadCard] {
        rounds.first(where: { $0.index == index })?.cards ?? []
    }

    static func cards(forRound roundIndex: Int, subRoundIndex: Int) -> [RoadCard] {
        guard let round = rounds.first(where: { $0.index == roundIndex }), round.kind == .learning else {
            return []
        }
        let all = round.cards
        switch subRoundIndex {
        case 0:
            return all.filter { $0.direction == .metricToImperial }
        case 1:
            return all.filter { $0.direction == .imperialToMetric }
        case RoadGameConstants.mixedSubRoundIndex:
            return all
        default:
            return all
        }
    }

    static func subRoundLabel(majorRoundIndex: Int, subRoundIndex: Int) -> String {
        if majorRoundIndex == RoadGameConstants.finalExamRoundIndex {
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

    static func batchReviewItems(for cards: [RoadCard]) -> [ConversionReviewItem] {
        cards.map { card in
            ConversionReviewItem(
                id: card.id,
                source: reviewSource(for: card),
                target: reviewTarget(for: card)
            )
        }
    }

    static func reviewSource(for card: RoadCard) -> String {
        if let promptValue = card.promptValue, let promptUnit = card.promptUnit {
            return "\(promptValue)\(promptUnit)"
        }
        return sourceDisplay(for: card)
    }

    static func reviewTarget(for card: RoadCard) -> String {
        "≈ \(card.answerLabel)"
    }

    static func generateFinalExamQuestions(
        count: Int = RoadGameConstants.examQuestionCount
    ) -> [RoadCard] {
        var questions: [RoadCard] = []
        var usedIDs = Set<String>()

        for roundIndex in 0..<RoadGameConstants.learningRoundCount {
            let roundCards = cards(forRound: roundIndex)
            let shuffled = roundCards.shuffled()
            var added = 0
            for template in shuffled where added < RoadGameConstants.examQuestionsPerRound {
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

    private struct RoadAnchorPair {
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

    private struct RoadConceptAnchor {
        let metricPrompt: String
        let imperialPrompt: String
        let metricAnswer: String
        let imperialAnswer: String
        let label: String
    }

    private static func pairedCards(
        roundIndex: Int,
        kind: RoadCardKind,
        anchors: [RoadAnchorPair]
    ) -> [RoadCard] {
        anchors.flatMap { anchor in
            let metricCard = RoadCard(
                roundIndex: roundIndex,
                kind: kind,
                direction: .metricToImperial,
                prompt: anchor.metricToImperialPrompt,
                promptValue: anchor.metricPromptValue,
                promptUnit: anchor.metricPromptUnit,
                label: anchor.label,
                answerLabel: anchor.imperialAnswer
            )
            let imperialCard = RoadCard(
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

    private static func conceptCards(roundIndex: Int, anchors: [RoadConceptAnchor]) -> [RoadCard] {
        anchors.flatMap { anchor in
            [
                RoadCard(
                    roundIndex: roundIndex,
                    kind: .travelTimeAnchor,
                    direction: .metricToImperial,
                    prompt: anchor.metricPrompt,
                    label: anchor.label,
                    answerLabel: anchor.metricAnswer
                ),
                RoadCard(
                    roundIndex: roundIndex,
                    kind: .travelTimeAnchor,
                    direction: .imperialToMetric,
                    prompt: anchor.imperialPrompt,
                    label: anchor.label,
                    answerLabel: anchor.imperialAnswer
                ),
            ]
        }
    }

    private static func speedAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        label: String
    ) -> RoadAnchorPair {
        genericAnchor(
            kind: .speed,
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A sign shows \(metric). About how fast is that in mph?",
            imperialPrompt: "You're used to \(imperial). About how fast is that in km/h?",
            label: label
        )
    }

    private static func shortDistanceAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        label: String
    ) -> RoadAnchorPair {
        genericAnchor(
            kind: .shortDistance,
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A sign warns of something \(metric) ahead. About how far is that?",
            imperialPrompt: "A sign shows \(imperial). About how far is that in meters?",
            label: label
        )
    }

    private static func walkingAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        label: String
    ) -> RoadAnchorPair {
        genericAnchor(
            kind: .walkingDistance,
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A destination is \(metric) away. About how far is that in miles?",
            imperialPrompt: "Something is \(imperial) away. About how far is that in kilometers or meters?",
            label: label
        )
    }

    private static func drivingAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        label: String
    ) -> RoadAnchorPair {
        genericAnchor(
            kind: .drivingDistance,
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A sign says \(metric). About how far is that in miles?",
            imperialPrompt: "Your map shows \(imperial). About how far is that in kilometers?",
            label: label
        )
    }

    private static func genericAnchor(
        kind: RoadCardKind,
        metric: String,
        imperial: String,
        metricPrompt: String,
        imperialPrompt: String,
        label: String
    ) -> RoadAnchorPair {
        RoadAnchorPair(
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

    private static func sourceDisplay(for card: RoadCard) -> String {
        switch card.direction {
        case .metricToImperial:
            if card.prompt.contains(" km/h") || card.prompt.contains(" km") || card.prompt.contains(" m") {
                return extractMetricPhrase(from: card.prompt) ?? card.prompt
            }
            return card.prompt
        case .imperialToMetric:
            if card.prompt.contains(" mph") || card.prompt.contains(" miles") || card.prompt.contains(" ft") {
                return extractImperialPhrase(from: card.prompt) ?? card.prompt
            }
            return card.prompt
        }
    }

    private static func extractMetricPhrase(from prompt: String) -> String? {
        let patterns = [
            #"(\d[\d,./]*\s*(?:km/h|km|m))"#,
            #"(\d[\d,./]*\s*km/h)"#,
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
            #"(\d[\d,./]*\s*(?:mph|miles|ft))"#,
            #"(1/\d+\s*mile)"#,
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
        if cleaned.hasPrefix("1/") { return nil }
        if cleaned.hasPrefix("0.") { return nil }
        let digits = cleaned.prefix { $0.isNumber || $0 == "." }
        if digits.contains(".") { return nil }
        return Int(digits)
    }

    private static func parseUnitSuffix(from text: String) -> String? {
        if text.contains("km/h") { return " km/h" }
        if text.hasSuffix(" km") || text.hasSuffix("km") { return " km" }
        if text.hasSuffix(" m") || text.hasSuffix("m") { return " m" }
        if text.contains("mph") { return " mph" }
        if text.contains("miles") { return " miles" }
        if text.contains("ft") { return " ft" }
        if text.contains("mile") { return " mile" }
        return nil
    }

    private static func examCard(from template: RoadCard, examQuestionID: String) -> RoadCard {
        RoadCard(
            roundIndex: RoadGameConstants.finalExamRoundIndex,
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
