//
//  MetricUnitsCurriculum.swift
//  Metricize
//

import Foundation

enum MetricUnitsCurriculum {
    private static let allCards: [MetricUnitsCard] = [
        MetricUnitsCard(
            id: "temp-unit",
            prompt: "Which metric unit is used for everyday temperature?",
            choices: ["Celsius", "Fahrenheit", "Kelvin", "Rankine"],
            correctIndex: 0,
            group: .baseUnits,
            reviewSource: "Everyday temperature",
            reviewTarget: "Celsius"
        ),
        MetricUnitsCard(
            id: "weight-unit",
            prompt: "Which unit is commonly used for small weights in cooking?",
            choices: ["Grams", "Pounds", "Ounces", "Stones"],
            correctIndex: 0,
            group: .baseUnits,
            reviewSource: "Small cooking weights",
            reviewTarget: "Grams"
        ),
        MetricUnitsCard(
            id: "volume-unit",
            prompt: "Which unit measures liquid volume in the metric system?",
            choices: ["Liters", "Gallons", "Cups", "Fluid ounces"],
            correctIndex: 0,
            group: .baseUnits,
            reviewSource: "Liquid volume",
            reviewTarget: "Liters"
        ),
        MetricUnitsCard(
            id: "length-unit",
            prompt: "In the US we often use inches; in metric, comparable small lengths usually start with…",
            choices: ["Centimeters", "Miles", "Yards", "Feet"],
            correctIndex: 0,
            group: .baseUnits,
            reviewSource: "Small lengths (vs. inches)",
            reviewTarget: "Centimeters"
        ),
        MetricUnitsCard(
            id: "distance-unit",
            prompt: "Long distances in metric are usually measured in…",
            choices: ["Kilometers", "Miles", "Meters", "Hectometers"],
            correctIndex: 0,
            group: .baseUnits,
            reviewSource: "Long distances",
            reviewTarget: "Kilometers"
        ),
        MetricUnitsCard(
            id: "prefix-centi",
            prompt: "The prefix centi- means…",
            choices: ["One hundredth (1/100)", "One tenth (1/10)", "Ten times larger", "One thousandth (1/1000)"],
            correctIndex: 0,
            group: .prefixes,
            reviewSource: "centi-",
            reviewTarget: "1/100 of the base unit"
        ),
        MetricUnitsCard(
            id: "prefix-deci",
            prompt: "The prefix deci- means…",
            choices: ["One tenth (1/10)", "One hundredth (1/100)", "Ten times larger", "One thousand times larger"],
            correctIndex: 0,
            group: .prefixes,
            reviewSource: "deci-",
            reviewTarget: "1/10 of the base unit"
        ),
        MetricUnitsCard(
            id: "prefix-milli",
            prompt: "The prefix milli- means…",
            choices: ["One thousandth (1/1000)", "One hundredth (1/100)", "One tenth (1/10)", "One thousand times larger"],
            correctIndex: 0,
            group: .prefixes,
            reviewSource: "milli-",
            reviewTarget: "1/1000 of the base unit"
        ),
        MetricUnitsCard(
            id: "prefix-kilo",
            prompt: "The prefix kilo- means…",
            choices: ["One thousand times larger", "One hundred times larger", "One tenth (1/10)", "One hundredth (1/100)"],
            correctIndex: 0,
            group: .prefixes,
            reviewSource: "kilo-",
            reviewTarget: "1,000× the base unit"
        ),
        MetricUnitsCard(
            id: "decimeter",
            prompt: "A decimeter is…",
            choices: ["One tenth of a meter", "Ten meters", "One hundredth of a meter", "One thousand meters"],
            correctIndex: 0,
            group: .prefixes,
            reviewSource: "Decimeter",
            reviewTarget: "1/10 of a meter"
        ),
    ]

    static let roundIntroTips: [String] = [
        "You'll practice the base metric units and the prefixes that scale them up or down.",
        "Take your time on the review screens before each section — they show exactly what you'll be tested on.",
    ]

    static func tips(forRound roundIndex: Int) -> [String] {
        roundIntroTips
    }

    static func subRoundLabel(majorRoundIndex: Int, subRoundIndex: Int) -> String {
        "\(majorRoundIndex + 1).\(subRoundIndex + 1)"
    }

    static func cards(forSubRoundIndex subRoundIndex: Int) -> [MetricUnitsCard] {
        switch subRoundIndex {
        case 0:
            return allCards.filter { $0.group == .baseUnits }
        case 1:
            return allCards.filter { $0.group == .prefixes }
        case MetricUnitsGameConstants.mixedSubRoundIndex:
            return allCards
        default:
            return allCards
        }
    }

    static func subRoundReviewItems(subRoundIndex: Int) -> [ConversionReviewItem] {
        cards(forSubRoundIndex: subRoundIndex).map { card in
            ConversionReviewItem(
                id: card.id,
                source: card.reviewSource,
                target: card.reviewTarget
            )
        }
    }
}
