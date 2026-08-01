//
//  HereToThereProgressStoreTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class HereToThereProgressStoreTests: XCTestCase {
    func testGradualReleaseStartsAtFiveCards() {
        let store = HereToThereProgressStore()
        store.ensureReleasedCountInitialized(roundIndex: 0, subRoundIndex: 0)
        XCTAssertEqual(store.releasedCardCount(roundIndex: 0, subRoundIndex: 0), 5)
    }

    func testMixedSubRoundReleasesAllCardsImmediately() {
        let store = HereToThereProgressStore()
        let total = store.allCardsForSubRound(roundIndex: 0, subRoundIndex: HereToThereGameConstants.mixedSubRoundIndex).count
        XCTAssertEqual(store.releasedCardCount(roundIndex: 0, subRoundIndex: HereToThereGameConstants.mixedSubRoundIndex), total)
    }
}
