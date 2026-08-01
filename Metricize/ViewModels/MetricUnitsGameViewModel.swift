//
//  MetricUnitsGameViewModel.swift
//  Metricize
//

import Foundation
import Observation

enum MetricUnitsGamePhase: Equatable {
    case playing(MetricUnitsCard)
    case showingTip(tips: [String])
    case showingSubRoundReview(subRoundIndex: Int, items: [ConversionReviewItem])
    case moduleComplete
}

@Observable
@MainActor
final class MetricUnitsGameViewModel {
    let progressStore: MetricUnitsProgressStore

    private(set) var phase: MetricUnitsGamePhase = .playing(MetricUnitsCurriculum.cards(forSubRoundIndex: 0)[0])
    private(set) var feedback: AnswerFeedback = .none
    private(set) var isSubmitting = false
    private var lastCardID: String?

    init(progressStore: MetricUnitsProgressStore) {
        self.progressStore = progressStore
        resumeFromSavedState()
    }

    func resumeFromSavedState() {
        lastCardID = nil
        progressStore.normalizePosition()

        if progressStore.isModuleComplete {
            phase = .moduleComplete
            return
        }

        enterCurrentSubRound()
    }

    func submitAnswer(selectedIndex: Int, for card: MetricUnitsCard) {
        guard !isSubmitting else { return }
        isSubmitting = true

        let isCorrect = selectedIndex == card.correctIndex
        progressStore.recordAnswer(for: card, correct: isCorrect)

        if isCorrect {
            feedback = .exact(answer: 0, unit: card.choices[card.correctIndex])
        } else {
            feedback = .incorrect(
                correctAnswer: 0,
                unit: card.choices[card.correctIndex]
            )
        }

        Task {
            try? await Task.sleep(for: .milliseconds(isCorrect ? 1600 : 2800))
            feedback = .none
            isSubmitting = false
            continueAfterAnswer()
        }
    }

    func dismissTipAndContinue() {
        guard case .showingTip = phase else { return }
        progressStore.markRoundTipSeen()
        enterCurrentSubRound()
    }

    func dismissSubRoundReviewAndContinue() {
        guard case .showingSubRoundReview(let subRoundIndex, _) = phase else { return }
        progressStore.acknowledgeSubRoundPreview(subRoundIndex: subRoundIndex)
        lastCardID = nil
        beginPracticingCurrentSubRound()
    }

    func resetModule() {
        progressStore.resetProgress()
        feedback = .none
        lastCardID = nil
        resumeFromSavedState()
    }

    func redoSubRound(subRoundIndex: Int) {
        feedback = .none
        lastCardID = nil
        progressStore.prepareToRedoSubRound(subRoundIndex: subRoundIndex)
        enterCurrentSubRound()
    }

    func choiceOrder(for card: MetricUnitsCard) -> [Int] {
        card.choices.indices.shuffled()
    }

    // MARK: - Private

    private func continueAfterAnswer() {
        if progressStore.isSubRoundComplete(progressStore.currentSubRoundIndex) {
            advanceFromCompletedSubRound()
        } else if let next = selectNextCard() {
            transitionToCard(next)
        }
    }

    private func advanceFromCompletedSubRound() {
        if progressStore.advanceSubRoundIfNeeded() {
            lastCardID = nil
            enterCurrentSubRound()
            return
        }

        if progressStore.isRoundComplete {
            progressStore.markPracticeComplete()
            phase = .moduleComplete
        }
    }

    private func beginPracticingCurrentSubRound() {
        if progressStore.isSubRoundComplete(progressStore.currentSubRoundIndex) {
            advanceFromCompletedSubRound()
            return
        }

        if let nextCard = selectNextCard() {
            transitionToCard(nextCard)
        }
    }

    private func enterCurrentSubRound() {
        if progressStore.currentSubRoundIndex == 0,
           progressStore.shouldShowRoundTip() {
            phase = .showingTip(tips: MetricUnitsCurriculum.tips(forRound: 0))
            return
        }

        if presentSubRoundReviewIfNeeded() {
            return
        }

        if progressStore.isSubRoundComplete(progressStore.currentSubRoundIndex) {
            advanceFromCompletedSubRound()
            return
        }

        if let nextCard = selectNextCard() {
            transitionToCard(nextCard)
        }
    }

    private func transitionToCard(_ card: MetricUnitsCard) {
        if progressStore.shouldShowSubRoundPreview(subRoundIndex: progressStore.currentSubRoundIndex) {
            presentSubRoundReviewIfNeeded()
            return
        }

        lastCardID = card.id
        phase = .playing(card)
    }

    @discardableResult
    private func presentSubRoundReviewIfNeeded() -> Bool {
        let subRoundIndex = progressStore.currentSubRoundIndex
        guard progressStore.shouldShowSubRoundPreview(subRoundIndex: subRoundIndex) else {
            return false
        }

        let items = MetricUnitsCurriculum.subRoundReviewItems(subRoundIndex: subRoundIndex)
        guard !items.isEmpty else { return false }

        phase = .showingSubRoundReview(subRoundIndex: subRoundIndex, items: items)
        return true
    }

    private func selectNextCard(excluding excludedID: String? = nil) -> MetricUnitsCard? {
        let currentCards = progressStore.currentSubRoundCards()
        var unlearnedCurrent = currentCards.filter { !progressStore.progress(for: $0).isLearned }

        if progressStore.currentSubRoundIndex == MetricUnitsGameConstants.mixedSubRoundIndex {
            unlearnedCurrent = currentCards.filter { !progressStore.progress(for: $0).isMixedLearned }
        }

        let avoidID = excludedID ?? lastCardID
        if let avoidID {
            let withoutExcluded = unlearnedCurrent.filter { $0.id != avoidID }
            if !withoutExcluded.isEmpty {
                unlearnedCurrent = withoutExcluded
            }
        }

        guard !unlearnedCurrent.isEmpty else { return nil }

        var pool: [(card: MetricUnitsCard, weight: Int)] = []

        for card in unlearnedCurrent where card.id != avoidID {
            let progress = progressStore.progress(for: card)
            let weight: Int
            if progress.totalIncorrect > 0 && progress.consecutiveCorrect == 0 {
                weight = MetricUnitsGameConstants.strugglingCardWeight
            } else if progress.consecutiveCorrect > 0 {
                weight = MetricUnitsGameConstants.partialProgressWeight
            } else {
                weight = MetricUnitsGameConstants.currentRoundCardWeight
            }
            pool.append((card, weight))
        }

        if pool.isEmpty {
            pool = unlearnedCurrent.map { ($0, MetricUnitsGameConstants.currentRoundCardWeight) }
        }

        if progressStore.currentSubRoundIndex == MetricUnitsGameConstants.mixedSubRoundIndex {
            let reviewCards = MetricUnitsCurriculum.cards(forSubRoundIndex: 0)
                + MetricUnitsCurriculum.cards(forSubRoundIndex: 1)
            for card in reviewCards where progressStore.progress(for: card).isLearned && card.id != avoidID {
                pool.append((card, MetricUnitsGameConstants.reviewCardWeight))
            }
        }

        return weightedRandom(from: pool)
    }

    private func weightedRandom(from pool: [(card: MetricUnitsCard, weight: Int)]) -> MetricUnitsCard? {
        let total = pool.reduce(0) { $0 + $1.weight }
        guard total > 0 else { return pool.first?.card }
        var roll = Int.random(in: 0..<total)
        for entry in pool {
            roll -= entry.weight
            if roll < 0 { return entry.card }
        }
        return pool.last?.card
    }
}
