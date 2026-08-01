//
//  RoadProgressStoreTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class RoadProgressStoreTests: XCTestCase {
    func testSubRoundCompletionRequiresThreeCorrect() {
        let store = RoadProgressStore()
        let cards = RoadCurriculum.cards(forRound: 0, subRoundIndex: 0)
        guard let card = cards.first else {
            XCTFail("Expected cards in round 1.1")
            return
        }

        store.recordAnswer(for: card, correct: true)
        store.recordAnswer(for: card, correct: true)
        XCTAssertFalse(store.isSubRoundComplete(0, subRoundIndex: 0))

        store.recordAnswer(for: card, correct: true)
        XCTAssertFalse(store.isSubRoundComplete(0, subRoundIndex: 0))
    }

    func testExamPassThreshold() {
        XCTAssertEqual(RoadGameConstants.examPassCorrectCount, 20)
        XCTAssertEqual(RoadGameConstants.examQuestionCount, 25)
    }

    func testGradualReleaseInitialBatch() {
        let store = RoadProgressStore()
        store.ensureReleasedCountInitialized(roundIndex: 0, subRoundIndex: 0)
        XCTAssertEqual(store.releasedCardCount(roundIndex: 0, subRoundIndex: 0), RoadGameConstants.learningBatchSize)
    }
}
