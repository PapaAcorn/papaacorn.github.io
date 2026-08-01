//
//  HereToThereCurriculum.swift
//  Metricize
//

import Foundation

enum HereToThereCurriculum {
    static let rounds: [HereToThereRound] = [
        HereToThereRound(index: 0, title: "Inches and Small Lengths", kind: .learning, cards: round1Cards),
        HereToThereRound(index: 1, title: "Feet, Yards, and Everyday Distances", kind: .learning, cards: round2Cards),
        HereToThereRound(index: 2, title: "Rooms, Apartments, and Homes", kind: .learning, cards: round3Cards),
        HereToThereRound(index: 3, title: "Sheet Goods and Board Sizes", kind: .learning, cards: round4Cards),
        HereToThereRound(index: 4, title: "Construction Lumber and Project Dimensions", kind: .learning, cards: round5Cards),
        HereToThereRound(
            index: HereToThereGameConstants.finalExamRoundIndex,
            title: "Final Exam",
            kind: .finalExam,
            cards: []
        ),
    ]

    // MARK: - Round 1: Inches and Small Lengths

    private static let round1Cards: [HereToThereCard] = pairedCards(
        roundIndex: 0,
        kind: .smallLength,
        anchors: [
            smallLengthAnchor(metric: "5 mm", imperial: "1/4 inch", label: "Thin hardware gap"),
            smallLengthAnchor(metric: "10 mm", imperial: "3/8 inch", label: "Small drill bit size"),
            smallLengthAnchor(metric: "12 mm", imperial: "1/2 inch", label: "Shelf pin spacing"),
            smallLengthAnchor(metric: "20 mm", imperial: "3/4 inch", label: "Drawer slide clearance"),
            smallLengthAnchor(
                metric: "25 mm",
                imperial: "1 inch",
                metricPrompt: "A gap is 25 mm wide. About how wide is that in inches?",
                label: "One-inch mental anchor"
            ),
            smallLengthAnchor(metric: "50 mm", imperial: "2 inches", label: "Handle or knob width"),
            smallLengthAnchor(metric: "75 mm", imperial: "3 inches", label: "Screen bezel or trim"),
            smallLengthAnchor(metric: "100 mm", imperial: "4 inches", label: "Small package depth"),
            smallLengthAnchor(
                metric: "150 mm",
                imperial: "6 inches",
                metricPrompt: "A shelf bracket is 150 mm long. About how many inches is that?",
                label: "Bracket or shelf depth"
            ),
            smallLengthAnchor(metric: "200 mm", imperial: "8 inches", label: "Tablet or book width"),
            smallLengthAnchor(metric: "250 mm", imperial: "10 inches", label: "Laptop or tile width"),
            smallLengthAnchor(metric: "300 mm", imperial: "12 inches / 1 foot", label: "Ruler length"),
        ]
    )

    // MARK: - Round 2: Feet, Yards, and Everyday Distances

    private static let round2Cards: [HereToThereCard] = pairedCards(
        roundIndex: 1,
        kind: .everydayDistance,
        anchors: [
            everydayDistanceAnchor(metric: "30 cm", imperial: "1 foot", label: "Short step or tile"),
            everydayDistanceAnchor(metric: "45 cm", imperial: "18 inches", label: "Counter depth feel"),
            everydayDistanceAnchor(metric: "60 cm", imperial: "2 feet", label: "Small table width"),
            everydayDistanceAnchor(metric: "75 cm", imperial: "2.5 feet", label: "Desk or bench length"),
            everydayDistanceAnchor(metric: "90 cm", imperial: "3 feet / 1 yard", label: "Doorway or sofa width"),
            everydayDistanceAnchor(metric: "1 m", imperial: "3.3 feet", label: "Meter vs yard"),
            everydayDistanceAnchor(metric: "1.2 m", imperial: "4 feet", label: "Coffee table length"),
            everydayDistanceAnchor(metric: "1.5 m", imperial: "5 feet", label: "Twin bed length"),
            everydayDistanceAnchor(
                metric: "1.8 m",
                imperial: "6 feet",
                metricPrompt: "A table is 1.8 m long. About how many feet is that?",
                label: "Dining table length"
            ),
            everydayDistanceAnchor(metric: "2 m", imperial: "6.5 feet", label: "Queen bed length"),
            everydayDistanceAnchor(metric: "2.4 m", imperial: "8 feet", label: "Sheet goods length"),
            everydayDistanceAnchor(
                metric: "3 m",
                imperial: "10 feet",
                metricPrompt: "A room is 3 m wide. About how wide is that in feet?",
                label: "Small room width"
            ),
        ]
    )

    // MARK: - Round 3: Rooms, Apartments, and Homes

    private static let round3Cards: [HereToThereCard] = pairedCards(
        roundIndex: 2,
        kind: .livingArea,
        anchors: [
            livingAreaAnchor(metric: "10 m²", imperial: "100 sq ft", label: "Small bedroom or studio nook"),
            livingAreaAnchor(metric: "15 m²", imperial: "160 sq ft", label: "Compact bedroom"),
            livingAreaAnchor(metric: "20 m²", imperial: "215 sq ft", label: "Home office"),
            livingAreaAnchor(metric: "25 m²", imperial: "270 sq ft", label: "Large bedroom"),
            livingAreaAnchor(
                metric: "30 m²",
                imperial: "325 sq ft",
                metricPrompt: "A hotel suite is 30 m². About how much space is that?",
                label: "Studio apartment feel"
            ),
            livingAreaAnchor(metric: "40 m²", imperial: "430 sq ft", label: "One-bedroom flat"),
            livingAreaAnchor(
                metric: "50 m²",
                imperial: "540 sq ft",
                metricPrompt: "An apartment listing says 50 m². About how large is that in square feet?",
                label: "Typical one-bedroom listing"
            ),
            livingAreaAnchor(metric: "60 m²", imperial: "650 sq ft", label: "Two-room apartment"),
            livingAreaAnchor(metric: "75 m²", imperial: "800 sq ft", label: "Spacious two-bedroom"),
            livingAreaAnchor(metric: "90 m²", imperial: "1,000 sq ft", label: "Family apartment"),
            livingAreaAnchor(metric: "120 m²", imperial: "1,300 sq ft", label: "Large family flat"),
            livingAreaAnchor(metric: "150 m²", imperial: "1,600 sq ft", label: "House-sized listing"),
        ]
    )

    // MARK: - Round 4: Sheet Goods and Board Sizes

    private static let round4Cards: [HereToThereCard] = pairedCards(
        roundIndex: 3,
        kind: .sheetGoods,
        anchors: [
            sheetGoodsAnchor(
                metric: "6 mm plywood",
                imperial: "1/4 inch",
                metricPrompt: "A sheet of plywood is 6 mm thick. About what familiar plywood thickness is that?",
                imperialPrompt: "1/4 inch plywood is about how thick in millimeters?",
                label: "Thin plywood"
            ),
            sheetGoodsAnchor(metric: "9 mm plywood", imperial: "3/8 inch", label: "Light cabinet ply"),
            sheetGoodsAnchor(metric: "12 mm plywood", imperial: "1/2 inch", label: "Standard cabinet ply"),
            sheetGoodsAnchor(
                metric: "18 mm plywood",
                imperial: "3/4 inch",
                metricPrompt: "A sheet of plywood is 18 mm thick. About what familiar plywood thickness is that?",
                label: "Thick plywood"
            ),
            sheetGoodsAnchor(metric: "600 mm width", imperial: "2 feet", label: "Narrow panel width"),
            sheetGoodsAnchor(metric: "900 mm width", imperial: "3 feet", label: "Counter-depth panel"),
            sheetGoodsAnchor(metric: "1,200 mm width", imperial: "4 feet", label: "Standard panel width"),
            sheetGoodsAnchor(metric: "2,400 mm length", imperial: "8 feet", label: "Full sheet length"),
            sheetGoodsAnchor(
                metric: "1,220 × 2,440 mm sheet",
                imperial: "4 × 8 ft sheet",
                metricPrompt: "A lumber yard lists a 1,220 × 2,440 mm sheet. What familiar sheet size is that?",
                label: "Metric 4×8 equivalent"
            ),
            sheetGoodsAnchor(
                metric: "1,200 × 2,400 mm sheet",
                imperial: "close to 4 × 8 ft sheet",
                label: "Near-standard sheet"
            ),
            sheetGoodsAnchor(
                metric: "19 × 38 mm board",
                imperial: "1 × 2 nominal lumber",
                metricPrompt: "Trim is labeled 19 × 38 mm. What familiar lumber size is that close to?",
                label: "Thin strip lumber"
            ),
            sheetGoodsAnchor(
                metric: "38 × 89 mm board",
                imperial: "2 × 4 nominal lumber",
                metricPrompt: "A board is labeled 38 × 89 mm. What familiar lumber size is that close to?",
                label: "Framing lumber cross-section"
            ),
        ]
    )

    // MARK: - Round 5: Construction Lumber and Project Dimensions

    private static let round5Cards: [HereToThereCard] = pairedCards(
        roundIndex: 4,
        kind: .constructionLumber,
        anchors: [
            constructionLumberAnchor(
                metric: "25 × 50 mm",
                imperial: "1 × 2 lumber",
                metricPrompt: "A board is 25 × 50 mm. What common lumber size is that close to?",
                label: "Light trim lumber"
            ),
            constructionLumberAnchor(metric: "25 × 75 mm", imperial: "1 × 3 lumber", label: "Shelf cleat size"),
            constructionLumberAnchor(metric: "25 × 100 mm", imperial: "1 × 4 lumber", label: "Furring strip"),
            constructionLumberAnchor(
                metric: "38 × 89 mm",
                imperial: "2 × 4 lumber",
                metricPrompt: "Framing lumber is 38 × 89 mm. What common U.S. size is that close to?",
                label: "Standard wall stud"
            ),
            constructionLumberAnchor(
                metric: "38 × 140 mm",
                imperial: "2 × 6 lumber",
                metricPrompt: "A board is 38 × 140 mm. What common lumber size is that close to?",
                label: "Deck joist size"
            ),
            constructionLumberAnchor(metric: "89 × 89 mm", imperial: "4 × 4 post", label: "Fence or deck post"),
            constructionLumberAnchor(metric: "100 mm", imperial: "4 inches", label: "Handrail height chunk"),
            constructionLumberAnchor(metric: "150 mm", imperial: "6 inches", label: "Gutter or trim width"),
            constructionLumberAnchor(metric: "300 mm", imperial: "12 inches / 1 foot", label: "Tile or plank module"),
            constructionLumberAnchor(metric: "450 mm", imperial: "18 inches", label: "Cabinet depth module"),
            constructionLumberAnchor(metric: "600 mm", imperial: "2 feet", label: "Counter module"),
            constructionLumberAnchor(metric: "900 mm", imperial: "3 feet", label: "Base cabinet width"),
            constructionLumberAnchor(
                metric: "1,200 mm",
                imperial: "4 feet",
                metricPrompt: "A project panel is 1,200 mm wide. About how many feet is that?",
                label: "Panel width"
            ),
            constructionLumberAnchor(metric: "1,800 mm", imperial: "6 feet", label: "Door or tall panel"),
            constructionLumberAnchor(metric: "2,400 mm", imperial: "8 feet", label: "Full-length lumber"),
        ]
    )

    static let roundIntroTips: [Int: [String]] = [
        0: [
            "Small distances come up constantly: furniture dimensions, shelf depths, room sizes, apartment listings, construction materials, and DIY projects. This module teaches practical metric equivalents for the inches, feet, yards, square feet, and building materials Americans are most likely to recognize. The goal is not perfect calculation. The goal is useful mental reference points.",
            "Metric countries usually describe small lengths in millimeters or centimeters. A useful shortcut is that 25 mm is about 1 inch, and 30 cm is about 1 foot. This round starts with the inch-sized measurements Americans use constantly.",
            "These are practical approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
        ],
        1: [
            "Once a distance gets larger than a few inches, metric countries often use centimeters or meters. A good mental anchor is that 1 meter is a little longer than 1 yard, and 3 meters is about 10 feet.",
            "These are practical approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
        ],
        2: [
            "Outside the United States, apartments and homes are usually listed in square meters instead of square feet. A useful shortcut is that 1 square meter is about 11 square feet. For quick judgment, multiplying square meters by 10 gives a close mental estimate.",
            "These are practical approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
        ],
        3: [
            "Building materials are often sold in metric sizes outside the United States. Some common sizes are close to familiar American dimensions, but not always exact. This round teaches practical equivalents for sheet goods and board sizes.",
            "Metric lumber and nominal U.S. sizes are approximate equivalents — useful for recognition, not guaranteed exact substitutions.",
            "These are practical approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
        ],
        4: [
            "Metric lumber and project dimensions are often close to familiar American sizes, but the labels may look very different. These conversions are meant to help you recognize what you are looking at, not replace exact project measurements.",
            "These are practical approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
        ],
    ]

    static let finalExamIntroTips: [String] = [
        "You have learned small lengths, everyday distances, room and home sizes, sheet goods, and construction material references. This final exam mixes everything together. Score 80% or higher to complete the module.",
        "These are practical approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
    ]

    static func tips(forRound roundIndex: Int) -> [String] {
        if roundIndex == HereToThereGameConstants.finalExamRoundIndex {
            return finalExamIntroTips
        }
        return roundIntroTips[roundIndex] ?? ["Practice makes approximation instinctive."]
    }

    static func roundTitle(for roundIndex: Int) -> String {
        rounds.first(where: { $0.index == roundIndex })?.title ?? "Round \(roundIndex + 1)"
    }

    static var learningRounds: [HereToThereRound] {
        rounds.filter { $0.kind == .learning }
    }

    static var allCards: [HereToThereCard] {
        learningRounds.flatMap(\.cards)
    }

    static func cards(forRound index: Int) -> [HereToThereCard] {
        rounds.first(where: { $0.index == index })?.cards ?? []
    }

    static func cards(forRound roundIndex: Int, subRoundIndex: Int) -> [HereToThereCard] {
        guard let round = rounds.first(where: { $0.index == roundIndex }), round.kind == .learning else {
            return []
        }
        let all = round.cards
        switch subRoundIndex {
        case 0:
            return all.filter { $0.direction == .metricToImperial }
        case 1:
            return all.filter { $0.direction == .imperialToMetric }
        case HereToThereGameConstants.mixedSubRoundIndex:
            return all
        default:
            return all
        }
    }

    static func subRoundLabel(majorRoundIndex: Int, subRoundIndex: Int) -> String {
        if majorRoundIndex == HereToThereGameConstants.finalExamRoundIndex {
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

    static func batchReviewItems(for cards: [HereToThereCard]) -> [ConversionReviewItem] {
        cards.map { card in
            ConversionReviewItem(
                id: card.id,
                source: reviewSource(for: card),
                target: reviewTarget(for: card)
            )
        }
    }

    static func reviewSource(for card: HereToThereCard) -> String {
        if let promptValue = card.promptValue, let promptUnit = card.promptUnit {
            return "\(promptValue)\(promptUnit)"
        }
        return sourceDisplay(for: card)
    }

    static func reviewTarget(for card: HereToThereCard) -> String {
        "≈ \(card.answerLabel)"
    }

    static func generateFinalExamQuestions(
        count: Int = HereToThereGameConstants.examQuestionCount
    ) -> [HereToThereCard] {
        var questions: [HereToThereCard] = []
        var usedIDs = Set<String>()

        for roundIndex in 0..<HereToThereGameConstants.learningRoundCount {
            let roundCards = cards(forRound: roundIndex)
            let shuffled = roundCards.shuffled()
            var added = 0
            for template in shuffled where added < HereToThereGameConstants.examQuestionsPerRound {
                let examID = "exam-htt-r\(roundIndex)-\(template.id)"
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

    private struct HereToThereAnchorPair {
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
        kind: HereToThereCardKind,
        anchors: [HereToThereAnchorPair]
    ) -> [HereToThereCard] {
        anchors.flatMap { anchor in
            let metricCard = HereToThereCard(
                roundIndex: roundIndex,
                kind: kind,
                direction: .metricToImperial,
                prompt: anchor.metricToImperialPrompt,
                promptValue: anchor.metricPromptValue,
                promptUnit: anchor.metricPromptUnit,
                label: anchor.label,
                answerLabel: anchor.imperialAnswer
            )
            let imperialCard = HereToThereCard(
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

    private static func smallLengthAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        label: String
    ) -> HereToThereAnchorPair {
        genericAnchor(
            kind: .smallLength,
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "Something measures \(metric). About how long is that in inches?",
            imperialPrompt: "You're used to \(imperial). About how long is that in millimeters?",
            label: label
        )
    }

    private static func everydayDistanceAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        label: String
    ) -> HereToThereAnchorPair {
        genericAnchor(
            kind: .everydayDistance,
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A distance is \(metric). About how long is that in feet?",
            imperialPrompt: "You're used to \(imperial). About how long is that in centimeters or meters?",
            label: label
        )
    }

    private static func livingAreaAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        label: String
    ) -> HereToThereAnchorPair {
        genericAnchor(
            kind: .livingArea,
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A listing shows \(metric). About how large is that in square feet?",
            imperialPrompt: "You're used to \(imperial). About how large is that in square meters?",
            label: label
        )
    }

    private static func sheetGoodsAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        imperialPrompt: String? = nil,
        label: String
    ) -> HereToThereAnchorPair {
        genericAnchor(
            kind: .sheetGoods,
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A material is labeled \(metric). What familiar size is that close to?",
            imperialPrompt: imperialPrompt ?? "You're used to \(imperial). What is the rough metric equivalent?",
            label: label
        )
    }

    private static func constructionLumberAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        imperialPrompt: String? = nil,
        label: String
    ) -> HereToThereAnchorPair {
        genericAnchor(
            kind: .constructionLumber,
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A project spec lists \(metric). What familiar size is that close to?",
            imperialPrompt: imperialPrompt ?? "You're used to \(imperial). What is the rough metric equivalent?",
            label: label
        )
    }

    private static func genericAnchor(
        kind: HereToThereCardKind,
        metric: String,
        imperial: String,
        metricPrompt: String,
        imperialPrompt: String,
        label: String
    ) -> HereToThereAnchorPair {
        HereToThereAnchorPair(
            metricSource: metric,
            imperialSource: imperial,
            metricToImperialPrompt: metricPrompt,
            imperialToMetricPrompt: imperialPrompt,
            imperialAnswer: imperial,
            metricAnswer: metric,
            label: label,
            metricPromptValue: parseLeadingNumber(from: metric),
            metricPromptUnit: parseUnitSuffix(from: metric, kind: kind),
            imperialPromptValue: parseLeadingNumber(from: imperial),
            imperialPromptUnit: parseUnitSuffix(from: imperial, kind: kind)
        )
    }

    private static func sourceDisplay(for card: HereToThereCard) -> String {
        switch card.direction {
        case .metricToImperial:
            return card.prompt
        case .imperialToMetric:
            return card.prompt
        }
    }

    private static func parseLeadingNumber(from text: String) -> Int? {
        let cleaned = text.replacingOccurrences(of: ",", with: "")
        if cleaned.hasPrefix("1/") { return nil }
        if cleaned.contains("×") { return nil }
        if cleaned.contains(".") {
            let digits = cleaned.prefix { $0.isNumber || $0 == "." }
            if let value = Double(digits) {
                return value == floor(value) ? Int(value) : nil
            }
            return nil
        }
        let digits = cleaned.prefix { $0.isNumber }
        guard !digits.isEmpty else { return nil }
        return Int(digits)
    }

    private static func parseUnitSuffix(from text: String, kind: HereToThereCardKind) -> String? {
        if text.contains("m²") { return " m²" }
        if text.contains("sq ft") { return " sq ft" }
        if text.contains("mm") && !text.contains("×") { return " mm" }
        if text.hasSuffix(" cm") || text.hasSuffix("cm") { return " cm" }
        if text.hasSuffix(" m") || text == "1 m" || text.hasPrefix("1.") && text.hasSuffix(" m") { return " m" }
        if text.contains("inch") { return nil }
        if text.contains("feet") || text.contains("foot") || text.contains("yard") { return nil }
        if kind == .livingArea { return nil }
        return nil
    }

    private static func examCard(from template: HereToThereCard, examQuestionID: String) -> HereToThereCard {
        HereToThereCard(
            roundIndex: HereToThereGameConstants.finalExamRoundIndex,
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
