//
//  TemperatureCurriculum.swift
//  Metricize
//

import Foundation

enum TemperatureCurriculum {
    /// Environmental temperatures from -15°F to 110°F, introduced in rounds of five.
    static let rounds: [TemperatureRound] = [
        TemperatureRound(
            index: 0,
            title: "Major Milestones",
            cards: cards(forRound: 0, celsiusValues: [0, 10, 20, 37, 38], labels: [
                "Freezing point of water",
                "Cool spring or fall day (~50°F)",
                "Comfortable room temperature",
                "Very hot summer day",
                "Boiling hot — about 100°F",
            ])
        ),
        TemperatureRound(
            index: 1,
            title: "Everyday Range",
            cards: cards(forRound: 1, celsiusValues: [-10, 5, 15, 25, 30], labels: [
                "Bitter cold morning",
                "Chilly but above freezing",
                "Light jacket weather",
                "Warm afternoon",
                "Hot day at the beach",
            ])
        ),
        TemperatureRound(
            index: 2,
            title: "Cold Extremes",
            cards: cards(forRound: 2, celsiusValues: [-18, -5, 27, 35, 40], labels: [
                "Deep winter cold",
                "Just below freezing",
                "Warm summer evening",
                "Scorching afternoon",
                "Near the upper environmental limit",
            ])
        ),
        TemperatureRound(
            index: 3,
            title: "Full Environmental Range",
            cards: cards(forRound: 3, celsiusValues: [-26, 23, 32, 43, -15], labels: [
                "Coldest you'll likely encounter",
                "Pleasant spring day",
                "Hot summer midday",
                "Extreme heat (~110°F)",
                "Frigid but survivable outdoors",
            ])
        ),
    ]

    /// Tips shown between rounds — user advances manually; 1–2 per round.
    static let roundTips: [Int: [String]] = [
        0: [
            "0°C is the freezing point — think 32°F.",
            "Room temperature sits around 20°C, roughly 70°F.",
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

    private static func cards(
        forRound roundIndex: Int,
        celsiusValues: [Int],
        labels: [String]
    ) -> [TemperatureCard] {
        zip(celsiusValues, labels).enumerated().map { offset, pair in
            let challengeType: ChallengeType = offset.isMultiple(of: 2)
                ? .thermometerSlider
                : .multipleChoice
            return TemperatureCard(
                celsius: pair.0,
                roundIndex: roundIndex,
                challengeType: challengeType,
                label: pair.1
            )
        }
    }
}
