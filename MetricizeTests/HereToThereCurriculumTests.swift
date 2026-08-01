//
//  HereToThereCurriculumTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class HereToThereCurriculumTests: XCTestCase {
    func testLearningRoundCount() {
        XCTAssertEqual(HereToThereGameConstants.learningRoundCount, 5)
        XCTAssertEqual(HereToThereGameConstants.finalExamRoundIndex, 5)
        XCTAssertEqual(HereToThereCurriculum.learningRounds.count, 5)
    }

    func testSubRoundDirectionOrder() {
        let round0 = HereToThereCurriculum.cards(forRound: 0, subRoundIndex: 0)
        let round0Reverse = HereToThereCurriculum.cards(forRound: 0, subRoundIndex: 1)
        XCTAssertTrue(round0.allSatisfy { $0.direction == .metricToImperial })
        XCTAssertTrue(round0Reverse.allSatisfy { $0.direction == .imperialToMetric })
        XCTAssertEqual(round0.count, 12)
        XCTAssertEqual(round0Reverse.count, 12)
    }

    func testRound1SmallLengths() {
        let cards = HereToThereCurriculum.cards(forRound: 0, subRoundIndex: 0)
        let answers = Set(cards.map(\.answerLabel))
        XCTAssertTrue(answers.contains("1 inch"))
        XCTAssertTrue(answers.contains("6 inches"))
    }

    func testRound3LivingAreas() {
        let cards = HereToThereCurriculum.cards(forRound: 2, subRoundIndex: 0)
        XCTAssertEqual(cards.count, 12)
        XCTAssertTrue(cards.contains { $0.answerLabel == "540 sq ft" })
    }

    func testRoundAnchorsStayWithinLimit() {
        for roundIndex in 0..<HereToThereGameConstants.learningRoundCount {
            let metricCards = HereToThereCurriculum.cards(forRound: roundIndex, subRoundIndex: 0)
            XCTAssertLessThanOrEqual(metricCards.count, 15, "Round \(roundIndex + 1) exceeds 15 conversions")
        }
    }

    func testFinalExamQuestionCountAndDistribution() {
        let questions = HereToThereCurriculum.generateFinalExamQuestions()
        XCTAssertEqual(questions.count, HereToThereGameConstants.examQuestionCount)
        XCTAssertEqual(HereToThereGameConstants.examPassCorrectCount, 20)

        for roundIndex in 0..<HereToThereGameConstants.learningRoundCount {
            let kind = HereToThereCurriculum.cards(forRound: roundIndex).first?.kind
            XCTAssertNotNil(kind)
            let fromRound = questions.filter { $0.kind == kind }
            XCTAssertEqual(fromRound.count, HereToThereGameConstants.examQuestionsPerRound)
        }
    }

    func testFinalExamIntroTips() {
        let tips = HereToThereCurriculum.tips(forRound: HereToThereGameConstants.finalExamRoundIndex)
        XCTAssertTrue(tips.first?.contains("80%") == true)
    }

    func testRound1IntroIncludesModuleFraming() {
        let tips = HereToThereCurriculum.tips(forRound: 0)
        XCTAssertTrue(tips.first?.contains("mental reference points") == true)
    }
}
