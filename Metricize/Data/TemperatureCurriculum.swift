//
//  TemperatureCurriculum.swift
//  Metricize
//

import Foundation

enum TemperatureCurriculum {
    /// Environmental temperatures from -10°F to 110°F. Each round teaches 5 anchor
    /// conversions in both directions (10 cards per round).
    static let rounds: [TemperatureRound] = [
        TemperatureRound(
            index: 0,
            title: "Major Milestones",
            cards: cards(
                forRound: 0,
                celsiusValues: [0, 20, 37, 10, 25],
                labels: [
                    "Freezing point of water",
                    "Standard indoor room temperature",
                    "Standard human body temperature",
                    "Cool spring or fall day",
                    "Warm afternoon",
                ]
            )
        ),
        TemperatureRound(
            index: 1,
            title: "Everyday Range",
            cards: cards(
                forRound: 1,
                celsiusValues: [-10, 5, 15, 30, 35],
                labels: [
                    "Bitter cold morning",
                    "Chilly but above freezing",
                    "Light jacket weather",
                    "Hot day at the beach",
                    "Scorching afternoon",
                ]
            )
        ),
        TemperatureRound(
            index: 2,
            title: "Cold Extremes",
            cards: cards(
                forRound: 2,
                celsiusValues: [-18, -5, 27, 40, 43],
                labels: [
                    "Deep winter cold",
                    "Just below freezing",
                    "Warm summer evening",
                    "Near the upper environmental limit",
                    "Extreme heat (~\(TemperatureFormatting.symbol(fahrenheit: 110)))",
                ]
            )
        ),
        TemperatureRound(
            index: 3,
            title: "Full Environmental Range",
            cards: cards(
                forRound: 3,
                celsiusValues: [-23, 23, 32, -15, 38],
                labels: [
                    "Coldest you'll likely encounter",
                    "Pleasant spring day",
                    "Hot summer midday",
                    "Frigid but survivable outdoors",
                    "Very hot summer day (~\(TemperatureFormatting.symbol(fahrenheit: 100)))",
                ]
            )
        ),
    ]

    static let roundTips: [Int: [String]] = [
        0: [
            "0°C is the freezing point — think 32°F.",
            "Room temperature sits around 20°C, roughly 68°F. Body temp is about 37°C.",
        ],
        1: [
            "A Quick Rule of Thumb: For quick estimations of ambient temperature, double the C and add 30. This won't be 100% accurate, but will get you in the ballpark.",
            "10°C feels like 50°F — a classic cool-day anchor.",
        ],
        2: [
            "30°C is where summer starts to feel genuinely hot (~86°F).",
            "-18°C is a deep freeze — around 0°F.",
        ],
        3: [
            "A Quick Rule of Thumb: For quick estimations of ambient temperature, double the C and add 30. This won't be 100% accurate, but will get you in the ballpark.",
            "You've covered the full environmental range — trust your anchors.",
        ],
    ]

    static func tips(forRound roundIndex: Int) -> [String] {
        let tips = roundTips[roundIndex] ?? [
            "Practice makes approximation instinctive.",
        ]
        return Array(tips.prefix(2))
    }

    static var allCards: [TemperatureCard] {
        rounds.flatMap(\.cards)
    }

    static func cards(forRound index: Int) -> [TemperatureCard] {
        rounds.first(where: { $0.index == index })?.cards ?? []
    }

    static func cards(forRound roundIndex: Int, subRoundIndex: Int) -> [TemperatureCard] {
        let all = cards(forRound: roundIndex)
        switch subRoundIndex {
        case 0:
            return all.filter { $0.direction == .celsiusToFahrenheit }
        case 1:
            return all.filter { $0.direction == .fahrenheitToCelsius }
        default:
            return all
        }
    }

    static func subRoundLabel(majorRoundIndex: Int, subRoundIndex: Int) -> String {
        "\(majorRoundIndex + 1).\(subRoundIndex + 1)"
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
