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
    ]

    static let roundTips: [Int: [String]] = [
        0: [
            "32°F is freezing — that's 0°C.",
            "68°F feels like room temperature — about 20°C. Body temp is near 99°F (~37°C).",
        ],
        1: [
            "The tens in Celsius are your grid: -20, -10, 0, 10, 30.",
            "A quick rule of thumb: double the °C and add 30 to estimate °F.",
        ],
        2: [
            "The fives fill in between the tens you already know.",
            "Close enough counts — you only need to be within 3°.",
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
