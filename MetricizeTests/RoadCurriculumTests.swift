//
//  RoadCurriculumTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class RoadCurriculumTests: XCTestCase {
    func testLearningRoundCount() {
        XCTAssertEqual(RoadGameConstants.learningRoundCount, 5)
        XCTAssertEqual(RoadGameConstants.finalExamRoundIndex, 5)
        XCTAssertEqual(RoadCurriculum.learningRounds.count, 5)
    }

    func testSubRoundDirectionOrder() {
        let round0 = RoadCurriculum.cards(forRound: 0, subRoundIndex: 0)
        let round0Reverse = RoadCurriculum.cards(forRound: 0, subRoundIndex: 1)
        XCTAssertTrue(round0.allSatisfy { $0.direction == .metricToImperial })
        XCTAssertTrue(round0Reverse.allSatisfy { $0.direction == .imperialToMetric })
        XCTAssertEqual(round0.count, 13)
        XCTAssertEqual(round0Reverse.count, 13)
    }

    func testRound1RoadSpeeds() {
        let cards = RoadCurriculum.cards(forRound: 0, subRoundIndex: 0)
        let answers = Set(cards.map(\.answerLabel))
        XCTAssertTrue(answers.contains("30 mph"))
        XCTAssertTrue(answers.contains("75 mph"))
    }

    func testRound2ShortDistances() {
        let cards = RoadCurriculum.cards(forRound: 1, subRoundIndex: 0)
        XCTAssertEqual(cards.count, 10)
        XCTAssertTrue(cards.contains { $0.answerLabel == "1/4 mile" })
    }

    func testRoundAnchorsStayWithinLimit() {
        for roundIndex in 0..<RoadGameConstants.learningRoundCount {
            let metricCards = RoadCurriculum.cards(forRound: roundIndex, subRoundIndex: 0)
            XCTAssertLessThanOrEqual(metricCards.count, 15, "Round \(roundIndex + 1) exceeds 15 conversions")
        }
    }

    func testFinalExamQuestionCountAndDistribution() {
        let questions = RoadCurriculum.generateFinalExamQuestions()
        XCTAssertEqual(questions.count, RoadGameConstants.examQuestionCount)
        XCTAssertEqual(RoadGameConstants.examPassCorrectCount, 20)

        for roundIndex in 0..<RoadGameConstants.learningRoundCount {
            let kind = RoadCurriculum.cards(forRound: roundIndex).first?.kind
            XCTAssertNotNil(kind)
            let fromRound = questions.filter { $0.kind == kind }
            XCTAssertEqual(fromRound.count, RoadGameConstants.examQuestionsPerRound)
        }
    }

    func testFinalExamIntroTips() {
        let tips = RoadCurriculum.tips(forRound: RoadGameConstants.finalExamRoundIndex)
        XCTAssertTrue(tips.first?.contains("80%") == true)
    }
}
