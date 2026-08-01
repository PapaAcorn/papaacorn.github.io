//
//  KitchenCurriculumTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class KitchenCurriculumTests: XCTestCase {
    func testLearningRoundCount() {
        XCTAssertEqual(KitchenGameConstants.learningRoundCount, 5)
        XCTAssertEqual(KitchenGameConstants.finalExamRoundIndex, 5)
        XCTAssertEqual(KitchenCurriculum.learningRounds.count, 5)
    }

    func testRound1CoreAnchors() {
        let cards = KitchenCurriculum.cards(forRound: 0)
        let imperialPrompts = Set(cards.filter { $0.direction == .imperialToMetric }.map(\.prompt))
        XCTAssertTrue(imperialPrompts.contains("1 teaspoon"))
        XCTAssertTrue(imperialPrompts.contains("1 tablespoon"))
        XCTAssertTrue(imperialPrompts.contains("1 fluid ounce"))
        XCTAssertTrue(imperialPrompts.contains("1 cup"))
        XCTAssertTrue(imperialPrompts.contains("1 pint"))
        XCTAssertTrue(imperialPrompts.contains("1 quart"))
        XCTAssertTrue(imperialPrompts.contains("1 ounce (by weight)"))
        XCTAssertTrue(imperialPrompts.contains("1 pound"))
    }

    func testRound2RecipeQuantities() {
        let cards = KitchenCurriculum.cards(forRound: 1)
        let imperialPrompts = Set(cards.filter { $0.direction == .imperialToMetric }.map(\.prompt))
        XCTAssertTrue(imperialPrompts.contains("1/4 teaspoon"))
        XCTAssertTrue(imperialPrompts.contains("1/2 cup"))
        XCTAssertTrue(imperialPrompts.contains("3/4 cup"))
        XCTAssertTrue(imperialPrompts.contains("2 cups"))
        XCTAssertTrue(imperialPrompts.contains("4 cups"))
    }

    func testRound3IngredientWeights() {
        let cards = KitchenCurriculum.cards(forRound: 2)
        let imperialPrompts = Set(cards.filter { $0.direction == .imperialToMetric }.map(\.prompt))
        XCTAssertTrue(imperialPrompts.contains("1 cup all-purpose flour"))
        XCTAssertTrue(imperialPrompts.contains("1 cup granulated sugar"))
        XCTAssertTrue(imperialPrompts.contains("1 stick butter (1/2 cup)"))
        XCTAssertFalse(imperialPrompts.contains("1 cup water"))
    }

    func testRound4OvenAndSafetyTemps() {
        let cards = KitchenCurriculum.cards(forRound: 3)
        let ovenCards = cards.filter { $0.kind == .ovenTemperature && $0.direction == .imperialToMetric }
        let fahrenheitValues = Set(ovenCards.compactMap(\.promptValue))
        XCTAssertTrue(fahrenheitValues.contains(350))
        XCTAssertTrue(fahrenheitValues.contains(400))
        XCTAssertTrue(fahrenheitValues.contains(450))

        let safetyCards = cards.filter { $0.kind == .foodSafetyTemperature }
        XCTAssertTrue(safetyCards.contains { $0.correctAnswer == 165 && $0.answerUnit == "°F" })
        XCTAssertTrue(safetyCards.contains { $0.correctAnswer == 74 && $0.answerUnit == "°C" })
        XCTAssertTrue(safetyCards.allSatisfy(\.requiresExactAnswer))
    }

    func testRound5PanAndDishSizes() {
        let cards = KitchenCurriculum.cards(forRound: 4)
        XCTAssertTrue(cards.allSatisfy { $0.challengeType == .multipleChoice })
        XCTAssertTrue(cards.allSatisfy { $0.kind == .panSize })

        let imperialPrompts = Set(cards.filter { $0.direction == .imperialToMetric }.map(\.prompt))
        XCTAssertTrue(imperialPrompts.contains("8 × 8 inch square pan"))
        XCTAssertTrue(imperialPrompts.contains("9 × 13 inch baking dish"))
        XCTAssertTrue(imperialPrompts.contains("9 inch round cake pan"))
        XCTAssertTrue(imperialPrompts.contains("9 × 5 inch loaf pan"))

        let eightByEight = cards.first { $0.prompt == "8 × 8 inch square pan" }
        XCTAssertEqual(eightByEight?.answerLabel, "20 × 20 cm")
    }

    func testFinalExamCoversAllRoundCategories() {
        let questions = KitchenCurriculum.generateFinalExamQuestions()
        XCTAssertEqual(questions.count, KitchenGameConstants.examQuestionCount)

        XCTAssertTrue(questions.contains { $0.kind == .volume })
        XCTAssertTrue(questions.contains { $0.kind == .weight })
        XCTAssertTrue(questions.contains { $0.kind == .ovenTemperature })
        XCTAssertTrue(questions.contains { $0.kind == .foodSafetyTemperature })
        XCTAssertTrue(questions.contains { $0.kind == .booleanComparison })
        XCTAssertTrue(questions.contains { $0.kind == .panSize })
        XCTAssertTrue(questions.contains { $0.kind == .panConcept })
    }

    func testOvenExamQuestionsWorkBothDirections() {
        let questions = KitchenCurriculum.generateFinalExamQuestions()
        let ovenQuestions = questions.filter { $0.kind == .ovenTemperature }
        XCTAssertTrue(ovenQuestions.contains { $0.direction == .imperialToMetric })
        XCTAssertTrue(ovenQuestions.contains { $0.direction == .metricToImperial })
    }

    func testFoodSafetyRejectsUnsafeLowerAnswers() {
        let card = KitchenCard(
            roundIndex: 4,
            kind: .foodSafetyTemperature,
            direction: .imperialToMetric,
            challengeType: .multipleChoice,
            prompt: "Poultry",
            correctAnswer: 165,
            answerUnit: "°F",
            requiresExactAnswer: true,
            alternateExactAnswer: 74
        )

        XCTAssertEqual(KitchenConversion.evaluate(guess: 165, for: card, tolerance: 0), .exact)
        XCTAssertEqual(KitchenConversion.evaluate(guess: 74, for: card, tolerance: 0), .exact)
        XCTAssertEqual(KitchenConversion.evaluate(guess: 160, for: card, tolerance: 0), .incorrect)
        XCTAssertEqual(KitchenConversion.evaluate(guess: 145, for: card, tolerance: 0), .incorrect)
        XCTAssertEqual(KitchenConversion.evaluate(guess: 180, for: card, tolerance: 0), .incorrect)
    }

    func testVolumeConversionRequiresExactAnswer() {
        let card = KitchenCard(
            roundIndex: 0,
            kind: .volume,
            direction: .imperialToMetric,
            challengeType: .multipleChoice,
            prompt: "1 cup",
            correctAnswer: 240,
            answerUnit: " mL"
        )
        XCTAssertEqual(KitchenConversion.evaluate(guess: 240, for: card, tolerance: 0), .exact)
        XCTAssertEqual(KitchenConversion.evaluate(guess: 243, for: card, tolerance: 0), .incorrect)
    }

    func testSliderDefaultDoesNotStartOnCorrectAnswer() {
        let card = KitchenCard(
            roundIndex: 0,
            kind: .volume,
            direction: .metricToImperial,
            challengeType: .measurementSlider,
            prompt: "240 mL",
            correctAnswer: 1,
            answerUnit: " cup"
        )
        let defaultValue = KitchenConversion.neutralSliderDefault(for: card)
        XCTAssertNotEqual(Int(defaultValue.rounded()), card.correctAnswer)
    }

    func testPoundDistractorsAreSpreadApart() {
        let card = KitchenCard(
            roundIndex: 0,
            kind: .weight,
            direction: .imperialToMetric,
            challengeType: .multipleChoice,
            prompt: "1 pound",
            correctAnswer: 450,
            answerUnit: " g"
        )
        let candidates = KitchenConversion.distractorCandidates(for: card)
            .filter { $0 != 450 && abs($0 - 450) >= KitchenConversion.minimumDistractorSeparation(for: card) }
        XCTAssertTrue(candidates.contains(120))
        XCTAssertTrue(candidates.contains(30))
        XCTAssertFalse(candidates.contains(455))
    }
}
