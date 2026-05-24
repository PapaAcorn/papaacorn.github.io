import Foundation

enum ConversionDirection: String, Codable, CaseIterable {
    case celsiusToFahrenheit
    case fahrenheitToCelsius

    var usesSlider: Bool {
        self == .celsiusToFahrenheit
    }
}

struct TemperatureCard: Identifiable, Codable, Equatable {
    let id: String
    let celsius: Int
    let fahrenheit: Int
    let round: Int
    let phrase: String
    let tip: String

    func questionKey(for direction: ConversionDirection) -> String {
        "\(id):\(direction.rawValue)"
    }
}

enum TemperatureDeck {
    static let environmentalFahrenheitRange = -15...110

    /// Five-card rounds for everyday environmental temperatures (-15°F … 110°F).
    static let cards: [TemperatureCard] = [
    // Round 1 — anchor milestones and range endpoints
    TemperatureCard(
      id: "freezing",
      celsius: 0,
      fahrenheit: 32,
      round: 1,
      phrase: "Freezing water",
      tip: "0°C is 32°F — freezing is not zero Fahrenheit."
    ),
    TemperatureCard(
      id: "cool-jacket",
      celsius: 10,
      fahrenheit: 50,
      round: 1,
      phrase: "Cool jacket weather",
      tip: "10°C lands on 50°F — an easy midpoint to memorize."
    ),
    TemperatureCard(
      id: "very-hot",
      celsius: 38,
      fahrenheit: 100,
      round: 1,
      phrase: "Very hot outside",
      tip: "100°F is about 38°C — think high thirties Celsius for triple-digit heat."
    ),
    TemperatureCard(
      id: "bitter-cold",
      celsius: -26,
      fahrenheit: -15,
      round: 1,
      phrase: "Bitter cold outdoors",
      tip: "-15°F is about -26°C — deep winter cold, well below freezing."
    ),
    TemperatureCard(
      id: "scorching",
      celsius: 43,
      fahrenheit: 110,
      round: 1,
      phrase: "Extreme summer heat",
      tip: "110°F is about 43°C — the top of everyday outdoor heat."
    ),

    // Round 2 — common daily temperatures
    TemperatureCard(
      id: "cold-above-freeze",
      celsius: 5,
      fahrenheit: 41,
      round: 2,
      phrase: "Cold, above freezing",
      tip: "5°C is about 40°F — from freezing, each 5°C step is roughly 9°F."
    ),
    TemperatureCard(
      id: "mild-spring",
      celsius: 15,
      fahrenheit: 59,
      round: 2,
      phrase: "Mild spring day",
      tip: "15°C is about 60°F — a comfortable outdoor temperature."
    ),
    TemperatureCard(
      id: "room-comfort",
      celsius: 20,
      fahrenheit: 68,
      round: 2,
      phrase: "Comfortable room",
      tip: "20°C is 68°F — close enough to “about 70°F” for comfort."
    ),
    TemperatureCard(
      id: "warm-day",
      celsius: 25,
      fahrenheit: 77,
      round: 2,
      phrase: "Warm day",
      tip: "25°C is 77°F — mid-twenties Celsius are upper seventies Fahrenheit."
    ),
    TemperatureCard(
      id: "summer-heat",
      celsius: 30,
      fahrenheit: 86,
      round: 2,
      phrase: "Summer heat",
      tip: "30°C is 86°F — once Celsius hits the thirties, Fahrenheit is high eighties and up."
    ),

    // Round 3 — fill-in environmental neighbors
    TemperatureCard(
      id: "zero-f",
      celsius: -18,
      fahrenheit: 0,
      round: 3,
      phrase: "Zero Fahrenheit",
      tip: "0°F is about -18°C — a sharp cold day, not “mildly cool.”"
    ),
    TemperatureCard(
      id: "teens-f",
      celsius: -12,
      fahrenheit: 10,
      round: 3,
      phrase: "Cold morning",
      tip: "10°F is about -12°C — still seriously cold, not “almost freezing.”"
    ),
    TemperatureCard(
      id: "almost-100",
      celsius: 35,
      fahrenheit: 95,
      round: 3,
      phrase: "Very hot day",
      tip: "35°C is about 95°F — one small step from 100°F territory."
    ),
    TemperatureCard(
      id: "light-jacket",
      celsius: 4,
      fahrenheit: 39,
      round: 3,
      phrase: "Light jacket weather",
      tip: "4°C is about 40°F — just above freezing in Fahrenheit."
    ),
    TemperatureCard(
      id: "pleasant-outside",
      celsius: 21,
      fahrenheit: 70,
      round: 3,
      phrase: "Pleasant outside",
      tip: "21°C is about 70°F — a classic “nice day” pairing."
    ),
    ]

    static var maxRound: Int {
        cards.map(\.round).max() ?? 1
    }

    static func cards(in round: Int) -> [TemperatureCard] {
        cards.filter { $0.round == round }
    }
}

struct TemperatureQuestion: Equatable {
    let card: TemperatureCard
    let direction: ConversionDirection

    var key: String {
        card.questionKey(for: direction)
    }
}
