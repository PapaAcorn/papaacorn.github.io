import XCTest
@testable import MetricSense

final class TemperatureDeckTests: XCTestCase {
    func testSupportedCalculatorSurfaceIsTemperatureTrainerOnly() {
        XCTAssertEqual(CalculatorRegressionCases.supportedCategories, ["Temperature"])
        XCTAssertTrue(CalculatorRegressionCases.unsupportedCategories.contains("Distance / Length"))
        XCTAssertTrue(CalculatorRegressionCases.unsupportedCategories.contains("Free-form input parsing"))
    }

    func testTemperatureDeckContainsKnownGoodEnvironmentalAnchors() throws {
        let expected: [(id: String, celsius: Int, fahrenheit: Int, round: Int)] = [
            ("freezing", 0, 32, 1),
            ("cool-jacket", 10, 50, 1),
            ("very-hot", 38, 100, 1),
            ("bitter-cold", -26, -15, 1),
            ("scorching", 43, 110, 1),
            ("cold-above-freeze", 5, 41, 2),
            ("mild-spring", 15, 59, 2),
            ("room-comfort", 20, 68, 2),
            ("warm-day", 25, 77, 2),
            ("summer-heat", 30, 86, 2),
            ("zero-f", -18, 0, 3),
            ("teens-f", -12, 10, 3),
            ("almost-100", 35, 95, 3),
            ("light-jacket", 4, 39, 3),
            ("pleasant-outside", 21, 70, 3),
        ]

        XCTAssertEqual(TemperatureDeck.cards.count, expected.count)

        for expectedCard in expected {
            let card = try XCTUnwrap(TemperatureDeck.cards.first { $0.id == expectedCard.id })
            XCTAssertEqual(card.celsius, expectedCard.celsius, expectedCard.id)
            XCTAssertEqual(card.fahrenheit, expectedCard.fahrenheit, expectedCard.id)
            XCTAssertEqual(card.round, expectedCard.round, expectedCard.id)
            XCTAssertFalse(card.phrase.isEmpty, expectedCard.id)
            XCTAssertFalse(card.tip.isEmpty, expectedCard.id)
        }
    }

    func testTemperatureRegressionCasesMatchDeckWithinDisplayTolerance() throws {
        for regressionCase in CalculatorRegressionCases.temperature {
            let card = try cardMatching(regressionCase)

            if regressionCase.inputUnit == "°C" {
                XCTAssertEqual(Double(card.fahrenheit), regressionCase.expectedResult, accuracy: regressionCase.tolerance)
            } else {
                XCTAssertEqual(Double(card.celsius), regressionCase.expectedResult, accuracy: regressionCase.tolerance)
            }
        }
    }

    func testEveryCardHasBothSupportedConversionDirections() {
        let questions = GameEngine.allQuestions(upToRound: TemperatureDeck.maxRound)

        XCTAssertEqual(questions.count, TemperatureDeck.cards.count * ConversionDirection.allCases.count)

        for card in TemperatureDeck.cards {
            XCTAssertTrue(questions.contains(TemperatureQuestion(card: card, direction: .celsiusToFahrenheit)))
            XCTAssertTrue(questions.contains(TemperatureQuestion(card: card, direction: .fahrenheitToCelsius)))
        }
    }

    func testTemperatureDeckRangeMatchesDocumentedEnvironmentalSupport() {
        XCTAssertEqual(TemperatureDeck.environmentalFahrenheitRange.lowerBound, -15)
        XCTAssertEqual(TemperatureDeck.environmentalFahrenheitRange.upperBound, 110)
        XCTAssertEqual(TemperatureDeck.maxRound, 3)
    }

    private func cardMatching(_ regressionCase: ConversionRegressionCase) throws -> TemperatureCard {
        if regressionCase.inputUnit == "°C" {
            return try XCTUnwrap(
                TemperatureDeck.cards.first { Double($0.celsius) == regressionCase.inputValue },
                regressionCase.notes
            )
        }

        return try XCTUnwrap(
            TemperatureDeck.cards.first { Double($0.fahrenheit) == regressionCase.inputValue },
            regressionCase.notes
        )
    }
}
