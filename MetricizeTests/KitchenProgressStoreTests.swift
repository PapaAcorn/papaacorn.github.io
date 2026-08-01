//
//  KitchenProgressStoreTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class KitchenProgressStoreTests: XCTestCase {
    func testMixedSubRoundRequiresPractice() {
        let store = KitchenProgressStore()
        store.resetProgress()

        for subRoundIndex in 0..<KitchenGameConstants.mixedSubRoundIndex {
            let cards = KitchenCurriculum.cards(forRound: 0, subRoundIndex: subRoundIndex)
            for card in cards {
                for _ in 0..<LearningPreferences.requiredConsecutiveCorrect {
                    store.recordAnswer(for: card, correct: true)
                }
            }
            XCTAssertTrue(store.advanceSubRoundIfNeeded())
        }

        XCTAssertEqual(store.currentSubRoundIndex, KitchenGameConstants.mixedSubRoundIndex)
        XCTAssertFalse(store.isSubRoundComplete(0, subRoundIndex: KitchenGameConstants.mixedSubRoundIndex))

        let mixedCards = KitchenCurriculum.cards(forRound: 0, subRoundIndex: KitchenGameConstants.mixedSubRoundIndex)
        XCTAssertGreaterThan(mixedCards.count, store.anchorCount(in: 0))

        for card in mixedCards {
            for _ in 0..<LearningPreferences.requiredConsecutiveCorrect {
                store.recordAnswer(for: card, correct: true)
            }
        }

        XCTAssertTrue(store.isSubRoundComplete(0, subRoundIndex: KitchenGameConstants.mixedSubRoundIndex))
    }

    func testFinalExamRequiresEightyPercent() {
        let store = KitchenProgressStore()
        store.resetProgress()

        var questions: [KitchenCard] = []
        for index in 0..<KitchenGameConstants.examQuestionCount {
            questions.append(
                KitchenCard(
                    roundIndex: KitchenGameConstants.finalExamRoundIndex,
                    kind: .volume,
                    direction: .imperialToMetric,
                    challengeType: .multipleChoice,
                    prompt: "test",
                    correctAnswer: 1,
                    answerUnit: " mL",
                    examQuestionID: "kitchen-test-q\(index)"
                )
            )
        }
        store.startFinalExamSession(questions)

        let passCount = KitchenGameConstants.examPassCorrectCount
        for _ in 0..<passCount {
            store.recordFinalExamAnswer(correct: true)
        }
        for _ in passCount..<KitchenGameConstants.examQuestionCount {
            store.recordFinalExamAnswer(correct: false)
        }

        guard let session = store.finalExamSession else {
            XCTFail("Expected exam session")
            return
        }
        XCTAssertEqual(session.correctCount, passCount)
        XCTAssertGreaterThanOrEqual(session.correctCount, KitchenGameConstants.examPassCorrectCount)
    }

    func testGradualReleaseIntroducesConversionsInBatches() {
        let store = KitchenProgressStore()
        store.resetProgress()

        let all = store.allCardsForSubRound(roundIndex: 0, subRoundIndex: 0)
        XCTAssertGreaterThan(all.count, KitchenGameConstants.learningBatchSize)

        XCTAssertTrue(store.shouldShowBatchReview(roundIndex: 0, subRoundIndex: 0))
        let firstPreview = store.cardsForBatchReview(roundIndex: 0, subRoundIndex: 0)
        XCTAssertEqual(firstPreview.count, KitchenGameConstants.learningBatchSize)

        store.acknowledgeBatchReview(roundIndex: 0, subRoundIndex: 0)
        XCTAssertFalse(store.shouldShowBatchReview(roundIndex: 0, subRoundIndex: 0))

        let initial = store.currentSubRoundCards()
        XCTAssertEqual(initial.count, KitchenGameConstants.learningBatchSize)

        for card in initial {
            for _ in 0..<LearningPreferences.requiredConsecutiveCorrect {
                store.recordAnswer(for: card, correct: true)
            }
        }

        XCTAssertTrue(store.isCurrentReleasedSetComplete(roundIndex: 0, subRoundIndex: 0))
        store.releaseNextBatchIfCurrentSetComplete(roundIndex: 0, subRoundIndex: 0)
        XCTAssertTrue(store.shouldShowBatchReview(roundIndex: 0, subRoundIndex: 0))

        let secondPreview = store.cardsForBatchReview(roundIndex: 0, subRoundIndex: 0)
        XCTAssertFalse(secondPreview.isEmpty)

        store.acknowledgeBatchReview(roundIndex: 0, subRoundIndex: 0)
        XCTAssertEqual(
            store.currentSubRoundCards().count,
            min(KitchenGameConstants.learningBatchSize * 2, all.count)
        )
    }

    func testMixedSubRoundDoesNotUseGradualRelease() {
        let store = KitchenProgressStore()
        XCTAssertFalse(store.usesGradualRelease(subRoundIndex: KitchenGameConstants.mixedSubRoundIndex))
        XCTAssertTrue(store.usesGradualRelease(subRoundIndex: 0))
    }
}
