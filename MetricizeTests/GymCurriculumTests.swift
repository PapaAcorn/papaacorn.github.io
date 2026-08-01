//
//  GymCurriculumTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class GymCurriculumTests: XCTestCase {
    func testLearningRoundCount() {
        XCTAssertEqual(GymGameConstants.learningRoundCount, 5)
        XCTAssertEqual(GymGameConstants.finalExamRoundIndex, 5)
        XCTAssertEqual(GymCurriculum.learningRounds.count, 5)
    }

    func testSubRoundDirectionOrder() {
        let round0 = GymCurriculum.cards(forRound: 0, subRoundIndex: 0)
        let round0Reverse = GymCurriculum.cards(forRound: 0, subRoundIndex: 1)
        XCTAssertTrue(round0.allSatisfy { $0.direction == .metricToImperial })
        XCTAssertTrue(round0Reverse.allSatisfy { $0.direction == .imperialToMetric })
        XCTAssertEqual(round0.count, 15)
        XCTAssertEqual(round0Reverse.count, 15)
    }

    func testRound1BodyWeight() {
        let cards = GymCurriculum.cards(forRound: 0, subRoundIndex: 0)
        let answers = Set(cards.map(\.answerLabel))
        XCTAssertTrue(answers.contains("175 lb"))
        XCTAssertTrue(answers.contains("220 lb"))
    }

    func testRound5CardioSpeeds() {
        let cards = GymCurriculum.cards(forRound: 4, subRoundIndex: 0)
        XCTAssertEqual(cards.count, 12)
        XCTAssertTrue(cards.contains { $0.answerLabel == "6 mph" })
        XCTAssertTrue(cards.contains { $0.answerLabel == "15 mph" })
    }

    func testRoundAnchorsStayWithinLimit() {
        for roundIndex in 0..<GymGameConstants.learningRoundCount {
            let metricCards = GymCurriculum.cards(forRound: roundIndex, subRoundIndex: 0)
            XCTAssertLessThanOrEqual(metricCards.count, 15, "Round \(roundIndex + 1) exceeds 15 conversions")
        }
    }

    func testFinalExamQuestionCountAndDistribution() {
        let questions = GymCurriculum.generateFinalExamQuestions()
        XCTAssertEqual(questions.count, GymGameConstants.examQuestionCount)
        XCTAssertEqual(GymGameConstants.examPassCorrectCount, 20)

        for roundIndex in 0..<GymGameConstants.learningRoundCount {
            let kind = GymCurriculum.cards(forRound: roundIndex).first?.kind
            XCTAssertNotNil(kind)
            let fromRound = questions.filter { $0.kind == kind }
            XCTAssertEqual(fromRound.count, GymGameConstants.examQuestionsPerRound)
        }
    }

    func testFinalExamIntroTips() {
        let tips = GymCurriculum.tips(forRound: GymGameConstants.finalExamRoundIndex)
        XCTAssertTrue(tips.first?.contains("80%") == true)
        XCTAssertTrue(tips.first?.contains("body-weight") == true || tips.first?.contains("body weight") == true)
    }

    func testRound4PlateCount() {
        let cards = GymCurriculum.cards(forRound: 3, subRoundIndex: 0)
        XCTAssertEqual(cards.count, 12)
    }
}
