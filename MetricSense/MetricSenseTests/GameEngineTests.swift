import XCTest
@testable import MetricSense

final class GameEngineTests: XCTestCase {
    func testQuestionCopyFormatsCelsiusToFahrenheitSliderPrompt() {
        let card = TemperatureCard(
            id: "body-ish",
            celsius: 37,
            fahrenheit: 99,
            round: 1,
            phrase: "Body temperature approximation",
            tip: "Body temperature is high thirties Celsius."
        )
        let question = TemperatureQuestion(card: card, direction: .celsiusToFahrenheit)

        let copy = GameEngine.questionCopy(for: question)

        XCTAssertEqual(copy.prompt, "Match this on the Fahrenheit thermometer")
        XCTAssertEqual(copy.givenValue, 37)
        XCTAssertEqual(copy.givenUnit, "°C")
        XCTAssertEqual(copy.target, 99)
        XCTAssertEqual(copy.answerUnit, "°F")
        XCTAssertEqual(copy.tolerance, GameConstants.fahrenheitTolerance)
        XCTAssertEqual(copy.sliderMin, -15)
        XCTAssertEqual(copy.sliderMax, 110)
        XCTAssertEqual(copy.correctSummary, "37°C is about 99°F.")
    }

    func testQuestionCopyFormatsFahrenheitToCelsiusMultipleChoicePrompt() {
        let card = TemperatureCard(
            id: "freezing",
            celsius: 0,
            fahrenheit: 32,
            round: 1,
            phrase: "Freezing water",
            tip: "0°C is 32°F."
        )
        let question = TemperatureQuestion(card: card, direction: .fahrenheitToCelsius)

        let copy = GameEngine.questionCopy(for: question)

        XCTAssertEqual(copy.prompt, "Which Celsius value is closest?")
        XCTAssertEqual(copy.givenValue, 32)
        XCTAssertEqual(copy.givenUnit, "°F")
        XCTAssertEqual(copy.target, 0)
        XCTAssertEqual(copy.answerUnit, "°C")
        XCTAssertEqual(copy.tolerance, GameConstants.celsiusTolerance)
        XCTAssertEqual(copy.sliderMin, -30)
        XCTAssertEqual(copy.sliderMax, 50)
        XCTAssertEqual(copy.correctSummary, "32°F is about 0°C.")
    }

    func testMultipleChoiceOptionsContainTargetAndExactlyFourReadableChoices() {
        for card in TemperatureDeck.cards {
            let question = TemperatureQuestion(card: card, direction: .fahrenheitToCelsius)

            let options = GameEngine.multipleChoiceOptions(for: question)

            XCTAssertEqual(options.count, 4, card.id)
            XCTAssertEqual(Set(options).count, 4, card.id)
            XCTAssertTrue(options.contains(card.celsius), card.id)
            XCTAssertEqual(options, options.sorted(), card.id)
            XCTAssertTrue(options.allSatisfy { (-30...50).contains($0) }, card.id)
        }
    }

    func testQuestionSelectionExcludesPreviousQuestionWhenAnotherChoiceExists() throws {
        let first = TemperatureQuestion(card: TemperatureDeck.cards[0], direction: .celsiusToFahrenheit)
        let second = TemperatureQuestion(card: TemperatureDeck.cards[1], direction: .celsiusToFahrenheit)

        let chosen = try XCTUnwrap(
            GameEngine.chooseQuestion(from: [first, second], progress: [:], excluding: first.key)
        )

        XCTAssertEqual(chosen, second)
    }

    func testUnlockedRoundAdvancesOnlyWhenEveryQuestionInCurrentRoundIsLearned() {
        XCTAssertEqual(GameEngine.unlockedRound(progress: [:]), 1)

        var progress: ProgressByQuestion = [:]
        for question in GameEngine.questions(forRound: 1) {
            progress[question.key] = QuestionProgress(attempts: 3, correct: 3, wrong: 0, streak: 3, learned: true)
        }

        XCTAssertEqual(GameEngine.unlockedRound(progress: progress), 2)

        for question in GameEngine.questions(forRound: 2) {
            progress[question.key] = QuestionProgress(attempts: 3, correct: 3, wrong: 0, streak: 3, learned: true)
        }

        XCTAssertEqual(GameEngine.unlockedRound(progress: progress), 3)
    }

    func testStartingSliderValueAvoidsCorrectAnswerNeighborhood() {
        let copy = QuestionCopy(
            prompt: "Match this on the Fahrenheit thermometer",
            givenValue: 20,
            givenUnit: "°C",
            target: 48,
            answerUnit: "°F",
            tolerance: 2,
            correctSummary: "20°C is about 68°F.",
            sliderMin: -15,
            sliderMax: 110
        )

        XCTAssertEqual(GameEngine.startingSliderValue(for: copy), -15)
    }
}
