//
//  TemperatureProgressStoreTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class TemperatureProgressStoreTests: XCTestCase {
    func testMixedSubRoundNotSkippedWhenEarlierCardsAlreadyLearned() {
        let store = TemperatureProgressStore()
        store.resetProgress()

        for subRoundIndex in 0..<TemperatureGameConstants.mixedSubRoundIndex {
            let cards = TemperatureCurriculum.cards(forRound: 0, subRoundIndex: subRoundIndex)
            for card in cards {
                for _ in 0..<LearningPreferences.requiredConsecutiveCorrect {
                    store.recordAnswer(for: card, correct: true)
                }
            }
            XCTAssertTrue(store.advanceSubRoundIfNeeded())
        }

        XCTAssertEqual(store.currentSubRoundIndex, TemperatureGameConstants.mixedSubRoundIndex)
        XCTAssertFalse(
            store.isSubRoundComplete(0, subRoundIndex: TemperatureGameConstants.mixedSubRoundIndex),
            "Round 1.3 should require mixed practice even when 1.1 and 1.2 cards are already learned"
        )

        let mixedCards = TemperatureCurriculum.cards(
            forRound: 0,
            subRoundIndex: TemperatureGameConstants.mixedSubRoundIndex
        )
        XCTAssertGreaterThan(mixedCards.count, store.anchorCount(in: 0))

        for card in mixedCards {
            for _ in 0..<LearningPreferences.requiredConsecutiveCorrect {
                store.recordAnswer(for: card, correct: true)
            }
        }

        XCTAssertTrue(
            store.isSubRoundComplete(0, subRoundIndex: TemperatureGameConstants.mixedSubRoundIndex)
        )
    }

    func testFinalExamRequiresEightyPercent() {
        let store = TemperatureProgressStore()
        store.resetProgress()

        var questions: [TemperatureCard] = []
        for index in 0..<TemperatureGameConstants.examQuestionCount {
            questions.append(
                TemperatureCard(
                    celsius: 0,
                    roundIndex: TemperatureGameConstants.finalExamRoundIndex,
                    challengeType: .multipleChoice,
                    direction: .celsiusToFahrenheit,
                    examQuestionID: "test-q\(index)"
                )
            )
        }
        store.startFinalExamSession(questions)

        let passCount = TemperatureGameConstants.examPassCorrectCount
        for index in 0..<passCount {
            store.recordFinalExamAnswer(correct: true)
        }
        for _ in passCount..<TemperatureGameConstants.examQuestionCount {
            store.recordFinalExamAnswer(correct: false)
        }

        guard let session = store.finalExamSession else {
            XCTFail("Expected exam session")
            return
        }
        XCTAssertEqual(session.correctCount, passCount)
        XCTAssertTrue(session.isComplete)
        XCTAssertGreaterThanOrEqual(session.correctCount, TemperatureGameConstants.examPassCorrectCount)
    }

    func testGenerateFinalExamQuestionsWithinBounds() {
        let questions = TemperatureCurriculum.generateFinalExamQuestions()
        XCTAssertEqual(questions.count, TemperatureGameConstants.examQuestionCount)

        var keys = Set<String>()
        for question in questions {
            let fahrenheit = question.correctFahrenheit
            XCTAssertTrue(TemperatureGameConstants.examFahrenheitRange.contains(fahrenheit))
            XCTAssertTrue(TemperatureGameConstants.examCelsiusRange.contains(question.celsius))
            keys.insert("\(question.celsius)-\(question.direction.rawValue)")
        }
        XCTAssertEqual(keys.count, questions.count, "Each exam question should appear once")
    }

    func testFinalExamAdvancesThroughQuestionsSequentially() {
        let store = TemperatureProgressStore()
        store.resetProgress()

        let questions = TemperatureCurriculum.generateFinalExamQuestions()
        store.startFinalExamSession(questions)

        XCTAssertTrue(store.isActiveFinalExamSession)
        XCTAssertEqual(store.currentExamCard()?.id, questions[0].id)
        XCTAssertEqual(store.examCorrectCount(), 0)
        XCTAssertEqual(store.examRemainingCount(), questions.count)

        store.recordFinalExamAnswer(correct: true)
        XCTAssertEqual(store.currentExamCard()?.id, questions[1].id)
        XCTAssertEqual(store.examCorrectCount(), 1)
        XCTAssertEqual(store.examRemainingCount(), questions.count - 1)

        store.recordFinalExamAnswer(correct: false)
        XCTAssertEqual(store.currentExamCard()?.id, questions[2].id)
        XCTAssertEqual(store.examCorrectCount(), 1)
        XCTAssertEqual(store.examRemainingCount(), questions.count - 2)
    }

    func testPrepareToRedoFinalExamClearsSessionWithoutClearingPassStatus() {
        let store = TemperatureProgressStore()
        store.resetProgress()
        completeAllLearningRounds(in: store)

        let questions = TemperatureCurriculum.generateFinalExamQuestions()
        store.startFinalExamSession(questions)
        for _ in 0..<questions.count {
            store.recordFinalExamAnswer(correct: true)
        }
        store.markFinalExamPassed()

        XCTAssertTrue(store.hasPassedFinalExam)
        XCTAssertNil(store.finalExamSession)

        store.prepareToRedoFinalExam()

        XCTAssertTrue(store.canAccessFinalExam)
        XCTAssertTrue(store.hasPassedFinalExam)
        XCTAssertEqual(store.currentRoundIndex, TemperatureGameConstants.finalExamRoundIndex)
        XCTAssertNil(store.finalExamSession)
    }

    private func completeAllLearningRounds(in store: TemperatureProgressStore) {
        for roundIndex in 0..<TemperatureGameConstants.learningRoundCount {
            for subRoundIndex in 0..<TemperatureGameConstants.subRoundsPerRound {
                let cards = TemperatureCurriculum.cards(forRound: roundIndex, subRoundIndex: subRoundIndex)
                for card in cards {
                    for _ in 0..<LearningPreferences.requiredConsecutiveCorrect {
                        store.recordAnswer(for: card, correct: true)
                    }
                }
                if subRoundIndex < TemperatureGameConstants.mixedSubRoundIndex {
                    XCTAssertTrue(store.advanceSubRoundIfNeeded())
                }
            }
            store.advanceToNextRoundIfNeeded()
        }
        XCTAssertTrue(store.areLearningRoundsComplete())
    }

    func testSubRoundPreviewBeforePractice() {
        let store = TemperatureProgressStore()
        store.resetProgress()

        XCTAssertTrue(store.shouldShowSubRoundPreview(roundIndex: 0, subRoundIndex: 0))
        let firstItems = TemperatureCurriculum.subRoundReviewItems(forRound: 0, subRoundIndex: 0)
        XCTAssertFalse(firstItems.isEmpty)

        store.acknowledgeSubRoundPreview(roundIndex: 0, subRoundIndex: 0)
        XCTAssertFalse(store.shouldShowSubRoundPreview(roundIndex: 0, subRoundIndex: 0))

        XCTAssertTrue(store.shouldShowSubRoundPreview(roundIndex: 0, subRoundIndex: 1))
        let secondItems = TemperatureCurriculum.subRoundReviewItems(forRound: 0, subRoundIndex: 1)
        XCTAssertFalse(secondItems.isEmpty)
        XCTAssertNotEqual(
            Set(firstItems.map(\.source)),
            Set(secondItems.map(\.source))
        )

        store.unmarkSubRoundPreview(roundIndex: 1, subRoundIndex: 0)
        XCTAssertTrue(store.shouldShowSubRoundPreview(roundIndex: 1, subRoundIndex: 0))
    }

    func testRoundTwoPreviewAfterCompletingRoundOne() {
        let store = TemperatureProgressStore()
        store.resetProgress()

        for subRoundIndex in 0..<TemperatureGameConstants.subRoundsPerRound {
            let cards = TemperatureCurriculum.cards(forRound: 0, subRoundIndex: subRoundIndex)
            for card in cards {
                for _ in 0..<LearningPreferences.requiredConsecutiveCorrect {
                    store.recordAnswer(for: card, correct: true)
                }
            }
            if subRoundIndex < TemperatureGameConstants.mixedSubRoundIndex {
                XCTAssertTrue(store.advanceSubRoundIfNeeded())
            }
        }

        XCTAssertTrue(store.isRoundComplete(0))
        store.advanceToNextRoundIfNeeded()
        store.unmarkTipSeen(forRound: 1)
        store.unmarkSubRoundPreview(roundIndex: 1, subRoundIndex: 0)

        XCTAssertEqual(store.currentRoundIndex, 1)
        XCTAssertEqual(store.currentSubRoundIndex, 0)
        XCTAssertTrue(store.shouldShowSubRoundPreview(roundIndex: 1, subRoundIndex: 0))

        let previewItems = TemperatureCurriculum.subRoundReviewItems(forRound: 1, subRoundIndex: 0)
        XCTAssertFalse(previewItems.isEmpty)
        XCTAssertEqual(previewItems.count, 5)
    }
}
