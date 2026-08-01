//
//  ShopCurriculum.swift
//  Metricize
//

import Foundation

enum ShopCurriculum {
    static let rounds: [ShopRound] = [
        ShopRound(index: 0, title: "Small Package Weights", kind: .learning, cards: round1Cards),
        ShopRound(index: 1, title: "Larger Grocery Weights", kind: .learning, cards: round2Cards),
        ShopRound(index: 2, title: "Bottles, Drinks, and Liquid Products", kind: .learning, cards: round3Cards),
        ShopRound(index: 3, title: "Clothing Measurements", kind: .learning, cards: round4Cards),
        ShopRound(index: 4, title: "Product Dimensions and Everyday Sizes", kind: .learning, cards: round5Cards),
        ShopRound(
            index: ShopGameConstants.finalExamRoundIndex,
            title: "Final Exam",
            kind: .finalExam,
            cards: []
        ),
    ]

    // MARK: - Round 1: Small Package Weights

    private static let round1Cards: [ShopCard] = pairedCards(
        roundIndex: 0,
        kind: .smallPackageWeight,
        anchors: [
            smallPackageAnchor(metric: "25 g", imperial: "1 oz", label: "Small snack portion"),
            smallPackageAnchor(metric: "50 g", imperial: "2 oz", label: "Candy or trial size"),
            smallPackageAnchor(metric: "75 g", imperial: "2.5 oz", label: "Small packaged treat"),
            smallPackageAnchor(
                metric: "100 g",
                imperial: "3.5 oz",
                metricPrompt: "A chocolate bar is 100 g. About how many ounces is that?",
                label: "Standard chocolate bar"
            ),
            smallPackageAnchor(metric: "125 g", imperial: "4 oz", label: "Small cheese portion"),
            smallPackageAnchor(metric: "150 g", imperial: "5 oz", label: "Deli snack pack"),
            smallPackageAnchor(metric: "200 g", imperial: "7 oz", label: "Coffee or tea bag"),
            smallPackageAnchor(
                metric: "250 g",
                imperial: "9 oz",
                metricPrompt: "A package of cheese is 250 g. About how much is that?",
                label: "Block of cheese"
            ),
            smallPackageAnchor(metric: "300 g", imperial: "10 oz", label: "Cosmetics or spreads"),
            smallPackageAnchor(metric: "400 g", imperial: "14 oz", label: "Medium packaged food"),
            smallPackageAnchor(metric: "450 g", imperial: "1 lb", label: "Near one-pound package"),
            smallPackageAnchor(metric: "500 g", imperial: "1.1 lb", label: "Half-kilo package"),
        ]
    )

    // MARK: - Round 2: Larger Grocery Weights

    private static let round2Cards: [ShopCard] = pairedCards(
        roundIndex: 1,
        kind: .largerGroceryWeight,
        anchors: [
            groceryWeightAnchor(metric: "0.5 kg", imperial: "1.1 lb", label: "Small bag of flour"),
            groceryWeightAnchor(metric: "0.75 kg", imperial: "1.5 lb", label: "Small meat portion"),
            groceryWeightAnchor(metric: "1 kg", imperial: "2.2 lb", label: "One-kilo reference"),
            groceryWeightAnchor(metric: "1.5 kg", imperial: "3.3 lb", label: "Family-size package"),
            groceryWeightAnchor(
                metric: "2 kg",
                imperial: "4.4 lb",
                metricPrompt: "A bag of rice is 2 kg. About how many pounds is that?",
                label: "Bag of rice"
            ),
            groceryWeightAnchor(metric: "2.5 kg", imperial: "5.5 lb", label: "Large produce bag"),
            groceryWeightAnchor(metric: "3 kg", imperial: "6.5 lb", label: "Bulk grocery item"),
            groceryWeightAnchor(metric: "4 kg", imperial: "9 lb", label: "Laundry powder small box"),
            groceryWeightAnchor(metric: "5 kg", imperial: "11 lb", label: "Large pet food bag"),
            groceryWeightAnchor(metric: "7.5 kg", imperial: "16.5 lb", label: "Heavy household goods"),
            groceryWeightAnchor(
                metric: "10 kg",
                imperial: "22 lb",
                metricPrompt: "A bag of dog food is 10 kg. About how heavy is that?",
                label: "Large pet food bag"
            ),
            groceryWeightAnchor(metric: "20 kg", imperial: "44 lb", label: "Bulk rice or pet food"),
        ]
    )

    // MARK: - Round 3: Bottles and Liquids

    private static let round3Cards: [ShopCard] = pairedCards(
        roundIndex: 2,
        kind: .bottleLiquid,
        anchors: [
            liquidAnchor(metric: "100 mL", imperial: "3.5 fl oz", label: "Mini bottle or sample"),
            liquidAnchor(metric: "150 mL", imperial: "5 fl oz", label: "Small drink bottle"),
            liquidAnchor(metric: "200 mL", imperial: "7 fl oz", label: "Travel-size bottle"),
            liquidAnchor(metric: "250 mL", imperial: "1 cup / 8 fl oz", label: "Single-serving drink"),
            liquidAnchor(metric: "330 mL", imperial: "11 fl oz", label: "Standard soda can size"),
            liquidAnchor(
                metric: "500 mL",
                imperial: "1 pint / 17 fl oz",
                metricPrompt: "A bottle is 500 mL. About how much is that?",
                label: "Water or soda bottle"
            ),
            liquidAnchor(metric: "750 mL", imperial: "25 fl oz", label: "Wine or spirits bottle"),
            liquidAnchor(metric: "1 L", imperial: "1 quart", label: "Milk or juice carton"),
            liquidAnchor(metric: "1.5 L", imperial: "1.5 quarts", label: "Large drink bottle"),
            liquidAnchor(
                metric: "2 L",
                imperial: "2 quarts",
                metricPrompt: "A detergent bottle is 2 L. About how many quarts is that?",
                label: "Detergent or soda bottle"
            ),
            liquidAnchor(metric: "3 L", imperial: "3 quarts", label: "Large household liquid"),
            liquidAnchor(metric: "4 L", imperial: "1 gallon", label: "Gallon-equivalent jug"),
            liquidAnchor(metric: "5 L", imperial: "1.3 gallons", label: "Large cleaning container"),
        ]
    )

    // MARK: - Round 4: Clothing Measurements

    private static let round4Cards: [ShopCard] = pairedCards(
        roundIndex: 3,
        kind: .clothingMeasurement,
        anchors: [
            clothingAnchor(metric: "30 cm", imperial: "12 inches", label: "Child or petite waist"),
            clothingAnchor(metric: "40 cm", imperial: "16 inches", label: "Small garment length"),
            clothingAnchor(metric: "50 cm", imperial: "20 inches", label: "Short sleeve or strap"),
            clothingAnchor(metric: "60 cm", imperial: "24 inches", label: "Inseam reference"),
            clothingAnchor(metric: "70 cm", imperial: "28 inches", label: "Waist measurement"),
            clothingAnchor(metric: "75 cm", imperial: "30 inches", label: "Common waist size"),
            clothingAnchor(metric: "80 cm", imperial: "32 inches", label: "Waist or hip measure"),
            clothingAnchor(
                metric: "85 cm",
                imperial: "34 inches",
                metricPrompt: "Jeans list the waist as 85 cm. About what waist size is that in inches?",
                label: "Jeans waist on label"
            ),
            clothingAnchor(metric: "90 cm", imperial: "36 inches", label: "Waist or chest measure"),
            clothingAnchor(metric: "95 cm", imperial: "38 inches", label: "Larger waist size"),
            clothingAnchor(
                metric: "100 cm",
                imperial: "40 inches",
                metricPrompt: "A belt is 100 cm. About how long is that in inches?",
                label: "Belt length"
            ),
            clothingAnchor(metric: "105 cm", imperial: "42 inches", label: "Long belt or strap"),
            clothingAnchor(metric: "110 cm", imperial: "44 inches", label: "Garment length"),
            clothingAnchor(metric: "115 cm", imperial: "46 inches", label: "Dress or coat length"),
            clothingAnchor(metric: "120 cm", imperial: "48 inches", label: "Long garment measure"),
        ]
    )

    // MARK: - Round 5: Product Dimensions

    private static let round5Cards: [ShopCard] = pairedCards(
        roundIndex: 4,
        kind: .productDimension,
        anchors: [
            dimensionAnchor(metric: "10 cm", imperial: "4 inches", label: "Small accessory"),
            dimensionAnchor(metric: "15 cm", imperial: "6 inches", label: "Handheld item width"),
            dimensionAnchor(metric: "20 cm", imperial: "8 inches", label: "Book or box depth"),
            dimensionAnchor(metric: "25 cm", imperial: "10 inches", label: "Small storage bin"),
            dimensionAnchor(metric: "30 cm", imperial: "12 inches / 1 foot", label: "Shelf depth reference"),
            dimensionAnchor(metric: "40 cm", imperial: "16 inches", label: "Carry-on width"),
            dimensionAnchor(metric: "50 cm", imperial: "20 inches", label: "Small luggage"),
            dimensionAnchor(
                metric: "60 cm",
                imperial: "2 feet",
                metricPrompt: "A storage bin is 60 cm wide. About how wide is that in feet?",
                label: "Storage bin width"
            ),
            dimensionAnchor(metric: "75 cm", imperial: "2.5 feet", label: "Desk or table width"),
            dimensionAnchor(metric: "90 cm", imperial: "3 feet", label: "Small rug width"),
            dimensionAnchor(metric: "100 cm", imperial: "1 meter / 3.3 feet", label: "Meter reference"),
            dimensionAnchor(metric: "120 cm", imperial: "4 feet", label: "Table or bench length"),
            dimensionAnchor(
                metric: "150 cm",
                imperial: "5 feet",
                metricPrompt: "A rug is 150 cm long. About how many feet is that?",
                label: "Rug length"
            ),
            dimensionAnchor(metric: "180 cm", imperial: "6 feet", label: "Tall furniture height"),
            dimensionAnchor(metric: "200 cm", imperial: "6.5 feet", label: "Large item length"),
        ]
    )

    static let roundIntroTips: [Int: [String]] = [
        0: [
            "Small packaged items are usually labeled in grams. A useful shortcut is that 100 g is about 3.5 ounces, and 500 g is a little over 1 pound. This round focuses on the gram amounts shoppers see most often.",
            "These are practical shopping approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
        ],
        1: [
            "Larger grocery and household items are usually labeled in kilograms. One kilogram is about 2.2 pounds. A half-kilogram is a little over 1 pound.",
            "These are practical shopping approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
        ],
        2: [
            "Liquids in stores are usually labeled in milliliters or liters. A useful shortcut is that 250 mL is about 1 cup, 500 mL is about 1 pint, and 1 liter is a little more than 1 quart.",
            "These are practical shopping approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
        ],
        3: [
            "Clothing measurements outside the United States may be given in centimeters. This is especially common for waist size, inseam or leg length, sleeve length, belts, and product dimensions. A useful shortcut is that 2.5 cm is about 1 inch.",
            "These are practical shopping approximations. Some values are rounded so they are easier to remember and useful in real-world situations. Centimeter numbers describe body or garment measurements on the label — not US/EU/UK size codes.",
        ],
        4: [
            "Product dimensions in stores are often listed in centimeters. These measurements help shoppers judge whether an item will fit: luggage, shelves, bins, rugs, furniture, boxes, and household items.",
            "These are practical shopping approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
        ],
    ]

    static let finalExamIntroTips: [String] = [
        "You have learned common store weights, grocery quantities, bottle sizes, clothing measurements, and product dimensions. This final exam mixes everything together. Score 80% or higher to complete the module.",
        "These are practical shopping approximations. Some values are rounded so they are easier to remember and useful in real-world situations.",
    ]

    static func tips(forRound roundIndex: Int) -> [String] {
        if roundIndex == ShopGameConstants.finalExamRoundIndex {
            return finalExamIntroTips
        }
        return roundIntroTips[roundIndex] ?? ["Practice makes approximation instinctive."]
    }

    static func roundTitle(for roundIndex: Int) -> String {
        rounds.first(where: { $0.index == roundIndex })?.title ?? "Round \(roundIndex + 1)"
    }

    static var learningRounds: [ShopRound] {
        rounds.filter { $0.kind == .learning }
    }

    static var allCards: [ShopCard] {
        learningRounds.flatMap(\.cards)
    }

    static func cards(forRound index: Int) -> [ShopCard] {
        rounds.first(where: { $0.index == index })?.cards ?? []
    }

    static func cards(forRound roundIndex: Int, subRoundIndex: Int) -> [ShopCard] {
        guard let round = rounds.first(where: { $0.index == roundIndex }), round.kind == .learning else {
            return []
        }
        let all = round.cards
        switch subRoundIndex {
        case 0:
            return all.filter { $0.direction == .metricToImperial }
        case 1:
            return all.filter { $0.direction == .imperialToMetric }
        case ShopGameConstants.mixedSubRoundIndex:
            return all
        default:
            return all
        }
    }

    static func subRoundLabel(majorRoundIndex: Int, subRoundIndex: Int) -> String {
        if majorRoundIndex == ShopGameConstants.finalExamRoundIndex {
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

    static func batchReviewItems(for cards: [ShopCard]) -> [ConversionReviewItem] {
        cards.map { card in
            ConversionReviewItem(
                id: card.id,
                source: reviewSource(for: card),
                target: reviewTarget(for: card)
            )
        }
    }

    static func reviewSource(for card: ShopCard) -> String {
        if let promptValue = card.promptValue, let promptUnit = card.promptUnit {
            return "\(promptValue)\(promptUnit)"
        }
        return sourceDisplay(for: card)
    }

    static func reviewTarget(for card: ShopCard) -> String {
        "≈ \(card.answerLabel)"
    }

    static func generateFinalExamQuestions(
        count: Int = ShopGameConstants.examQuestionCount
    ) -> [ShopCard] {
        var questions: [ShopCard] = []
        var usedIDs = Set<String>()

        for roundIndex in 0..<ShopGameConstants.learningRoundCount {
            let roundCards = cards(forRound: roundIndex)
            let shuffled = roundCards.shuffled()
            var added = 0
            for template in shuffled where added < ShopGameConstants.examQuestionsPerRound {
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

    private struct ShopAnchorPair {
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
        kind: ShopCardKind,
        anchors: [ShopAnchorPair]
    ) -> [ShopCard] {
        anchors.flatMap { anchor in
            let metricCard = ShopCard(
                roundIndex: roundIndex,
                kind: kind,
                direction: .metricToImperial,
                prompt: anchor.metricToImperialPrompt,
                promptValue: anchor.metricPromptValue,
                promptUnit: anchor.metricPromptUnit,
                label: anchor.label,
                answerLabel: anchor.imperialAnswer
            )
            let imperialCard = ShopCard(
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

    private static func smallPackageAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        label: String
    ) -> ShopAnchorPair {
        genericAnchor(
            kind: .smallPackageWeight,
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A package is labeled \(metric). About how much is that?",
            imperialPrompt: "A label shows \(imperial). About how many grams is that?",
            label: label
        )
    }

    private static func groceryWeightAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        label: String
    ) -> ShopAnchorPair {
        genericAnchor(
            kind: .largerGroceryWeight,
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A package weighs \(metric). About how many pounds is that?",
            imperialPrompt: "A label shows \(imperial). About how many kilograms is that?",
            label: label
        )
    }

    private static func liquidAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        label: String
    ) -> ShopAnchorPair {
        genericAnchor(
            kind: .bottleLiquid,
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A bottle holds \(metric). About how much is that?",
            imperialPrompt: "A label shows \(imperial). About how many milliliters or liters is that?",
            label: label
        )
    }

    private static func clothingAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        label: String
    ) -> ShopAnchorPair {
        genericAnchor(
            kind: .clothingMeasurement,
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A garment label shows \(metric). About how many inches is that?",
            imperialPrompt: "A size chart shows \(imperial). About how many centimeters is that?",
            label: label
        )
    }

    private static func dimensionAnchor(
        metric: String,
        imperial: String,
        metricPrompt: String? = nil,
        label: String
    ) -> ShopAnchorPair {
        genericAnchor(
            kind: .productDimension,
            metric: metric,
            imperial: imperial,
            metricPrompt: metricPrompt ?? "A product is \(metric) wide. About how wide is that in inches or feet?",
            imperialPrompt: "Dimensions list \(imperial). About how many centimeters is that?",
            label: label
        )
    }

    private static func genericAnchor(
        kind: ShopCardKind,
        metric: String,
        imperial: String,
        metricPrompt: String,
        imperialPrompt: String,
        label: String
    ) -> ShopAnchorPair {
        ShopAnchorPair(
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

    private static func sourceDisplay(for card: ShopCard) -> String {
        switch card.direction {
        case .metricToImperial:
            return extractMetricPhrase(from: card.prompt) ?? card.prompt
        case .imperialToMetric:
            return extractImperialPhrase(from: card.prompt) ?? card.prompt
        }
    }

    private static func extractMetricPhrase(from prompt: String) -> String? {
        let patterns = [
            #"(\d[\d,./]*\s*(?:kg|g|mL|L|cm))"#,
            #"(\d[\d,./]*\s*cm)"#,
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
            #"(\d[\d,./]*\s*(?:lb|oz|fl oz|inches|feet|quarts?|gallons?))"#,
            #"(1/\d+\s*(?:cup|pint))"#,
            #"(\d[\d,./]*\s*cup)"#,
            #"(\d[\d,./]*\s*feet)"#,
        ]
        for pattern in patterns {
            if let match = prompt.range(of: pattern, options: .regularExpression) {
                return String(prompt[match])
            }
        }
        if prompt.contains("1 pint") { return "1 pint / 17 fl oz" }
        if prompt.contains("1 cup") { return "1 cup / 8 fl oz" }
        if prompt.contains("1 meter") { return "1 meter / 3.3 feet" }
        if prompt.contains("12 inches / 1 foot") { return "12 inches / 1 foot" }
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

    private static func parseUnitSuffix(from text: String, kind: ShopCardKind) -> String? {
        if text.contains("mL") { return " mL" }
        if text.hasSuffix(" L") || text.hasSuffix("L") && text.contains(where: { $0.isNumber }) { return " L" }
        if text.hasSuffix(" g") || text.hasSuffix("g") && !text.contains("kg") { return " g" }
        if text.contains("kg") { return " kg" }
        if text.hasSuffix(" cm") || text.hasSuffix("cm") { return " cm" }
        if text.contains("fl oz") { return " fl oz" }
        if text.contains("oz") && !text.contains("fl") { return text.contains("2.5") ? " oz" : " oz" }
        if text.contains("lb") { return " lb" }
        if text.contains("inches") { return " inches" }
        if text.contains("feet") { return " feet" }
        if text.contains("quart") { return text.contains("1.5") ? " quarts" : " quart" }
        if text.contains("gallon") { return " gallons" }
        if text.contains("cup") { return " cup" }
        if text.contains("pint") { return " pint" }
        _ = kind
        return nil
    }

    private static func examCard(from template: ShopCard, examQuestionID: String) -> ShopCard {
        ShopCard(
            roundIndex: ShopGameConstants.finalExamRoundIndex,
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
