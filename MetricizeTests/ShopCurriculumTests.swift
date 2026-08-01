//
//  ShopCurriculumTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class ShopCurriculumTests: XCTestCase {
    func testLearningRoundCount() {
        XCTAssertEqual(ShopGameConstants.learningRoundCount, 5)
        XCTAssertEqual(ShopGameConstants.finalExamRoundIndex, 5)
        XCTAssertEqual(ShopCurriculum.learningRounds.count, 5)
    }

    func testSubRoundDirectionOrder() {
        let round0 = ShopCurriculum.cards(forRound: 0, subRoundIndex: 0)
        let round0Reverse = ShopCurriculum.cards(forRound: 0, subRoundIndex: 1)
        XCTAssertTrue(round0.allSatisfy { $0.direction == .metricToImperial })
        XCTAssertTrue(round0Reverse.allSatisfy { $0.direction == .imperialToMetric })
        XCTAssertEqual(round0.count, 12)
        XCTAssertEqual(round0Reverse.count, 12)
    }

    func testRound1SmallPackageWeights() {
        let cards = ShopCurriculum.cards(forRound: 0, subRoundIndex: 0)
        let answers = Set(cards.map(\.answerLabel))
        XCTAssertTrue(answers.contains("3.5 oz"))
        XCTAssertTrue(answers.contains("1.1 lb"))
    }

    func testRound3BottleLiquids() {
        let cards = ShopCurriculum.cards(forRound: 2, subRoundIndex: 0)
        XCTAssertEqual(cards.count, 13)
        XCTAssertTrue(cards.contains { $0.answerLabel == "1 gallon" })
    }

    func testRoundAnchorsStayWithinLimit() {
        for roundIndex in 0..<ShopGameConstants.learningRoundCount {
            let metricCards = ShopCurriculum.cards(forRound: roundIndex, subRoundIndex: 0)
            XCTAssertLessThanOrEqual(metricCards.count, 15, "Round \(roundIndex + 1) exceeds 15 conversions")
        }
    }

    func testFinalExamQuestionCountAndDistribution() {
        let questions = ShopCurriculum.generateFinalExamQuestions()
        XCTAssertEqual(questions.count, ShopGameConstants.examQuestionCount)
        XCTAssertEqual(ShopGameConstants.examPassCorrectCount, 20)

        for roundIndex in 0..<ShopGameConstants.learningRoundCount {
            let kind = ShopCurriculum.cards(forRound: roundIndex).first?.kind
            XCTAssertNotNil(kind)
            let fromRound = questions.filter { $0.kind == kind }
            XCTAssertEqual(fromRound.count, ShopGameConstants.examQuestionsPerRound)
        }
    }

    func testFinalExamIntroTips() {
        let tips = ShopCurriculum.tips(forRound: ShopGameConstants.finalExamRoundIndex)
        XCTAssertTrue(tips.first?.contains("80%") == true)
    }

    func testRound4ClothingMeasurements() {
        let cards = ShopCurriculum.cards(forRound: 3, subRoundIndex: 0)
        XCTAssertEqual(cards.count, 15)
        XCTAssertTrue(cards.contains { $0.prompt.contains("85 cm") })
    }
}
