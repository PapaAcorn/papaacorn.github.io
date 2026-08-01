//
//  ShopProgressStoreTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class ShopProgressStoreTests: XCTestCase {
    func testSubRoundCompletionRequiresThreeCorrect() {
        let store = ShopProgressStore()
        let cards = ShopCurriculum.cards(forRound: 0, subRoundIndex: 0)
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
        XCTAssertEqual(ShopGameConstants.examPassCorrectCount, 20)
        XCTAssertEqual(ShopGameConstants.examQuestionCount, 25)
    }

    func testGradualReleaseInitialBatch() {
        let store = ShopProgressStore()
        store.ensureReleasedCountInitialized(roundIndex: 0, subRoundIndex: 0)
        XCTAssertEqual(store.releasedCardCount(roundIndex: 0, subRoundIndex: 0), ShopGameConstants.learningBatchSize)
    }
}
