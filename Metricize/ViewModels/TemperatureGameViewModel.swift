//
//  TemperatureGameViewModel.swift
//  Metricize
//

import Foundation
import Observation

enum TemperatureGamePhase: Equatable {
    case playing(TemperatureCard)
    case showingTip(roundIndex: Int, tips: [String])
    case roundComplete(roundIndex: Int)
    case moduleComplete
}

enum AnswerFeedback: Equatable {
    case none
    case exact(answer: Int, unit: String)
    case closeEnough(answer: Int, unit: String)
    case incorrect(correctAnswer: Int, unit: String)
}

@Observable
@MainActor
final class TemperatureGameViewModel {
    let progressStore: TemperatureProgressStore

    private(set) var phase: TemperatureGamePhase = .playing(TemperatureCurriculum.rounds[0].cards[0])
    private(set) var feedback: AnswerFeedback = .none
    private(set) var isSubmitting = false
    private var lastCardID: String?

    init(progressStore: TemperatureProgressStore) {
        self.progressStore = progressStore
        resumeFromSavedState()
    }

    var currentRound: TemperatureRound {
        TemperatureCurriculum.rounds[progressStore.currentRoundIndex]
    }

    func resumeFromSavedState() {
        lastCardID = nil
        progressStore.normalizePosition()

        if progressStore.isModuleComplete {
            phase = .moduleComplete
            return
        }

        if progressStore.shouldShowTipBeforeRound(progressStore.currentRoundIndex)
            && progressStore.currentSubRoundIndex == 0 {
            showTip(for: progressStore.currentRoundIndex)
            return
        }

        if progressStore.isSubRoundComplete(
            progressStore.currentRoundIndex,
            subRoundIndex: progressStore.currentSubRoundIndex
        ) {
            advanceFromCompletedSubRound()
            return
        }

        if let nextCard = selectNextCard() {
            transitionToCard(nextCard)
        }
    }

    func submitSliderAnswer(guess: Int, for card: TemperatureCard) {
        submitAnswer(guess: guess, for: card)
    }

    func submitMultipleChoice(guess: Int, for card: TemperatureCard) {
        submitAnswer(guess: guess, for: card)
    }

    func dismissTipAndContinue() {
        guard case .showingTip(let roundIndex, _) = phase else { return }
        progressStore.markTipSeen(forRound: roundIndex)

        if let card = selectNextCard() {
            transitionToCard(card)
        } else if progressStore.isModuleComplete {
            phase = .moduleComplete
        }
    }

    func continueAfterRoundComplete() {
        guard case .roundComplete = phase else { return }
        resumeFromSavedState()
    }

    func resetModule() {
        progressStore.resetProgress()
        feedback = .none
        lastCardID = nil
        resumeFromSavedState()
    }

    // MARK: - Private

    private func submitAnswer(guess: Int, for card: TemperatureCard) {
        guard !isSubmitting else { return }
        isSubmitting = true

        let target = card.correctAnswer
        let result = TemperatureConversion.evaluate(guess: guess, target: target)
        let isCorrect = result != .incorrect
        progressStore.recordAnswer(for: card, correct: isCorrect)

        switch result {
        case .exact:
            feedback = .exact(answer: target, unit: card.answerUnit)
        case .closeEnough:
            feedback = .closeEnough(answer: target, unit: card.answerUnit)
        case .incorrect:
            feedback = .incorrect(correctAnswer: target, unit: card.answerUnit)
        }

        Task {
            try? await Task.sleep(for: .milliseconds(isCorrect ? 900 : 1600))
            feedback = .none
            isSubmitting = false
            continueAfterAnswer(for: card)
        }
    }

    private func continueAfterAnswer(for card: TemperatureCard) {
        if progressStore.isSubRoundComplete(
            progressStore.currentRoundIndex,
            subRoundIndex: progressStore.currentSubRoundIndex
        ) {
            advanceFromCompletedSubRound()
        } else if let next = selectNextCard() {
            transitionToCard(next)
        }
    }

    private func advanceFromCompletedSubRound() {
        if progressStore.advanceSubRoundIfNeeded() {
            lastCardID = nil
            if let next = selectNextCard() {
                transitionToCard(next)
            }
            return
        }

        if progressStore.isRoundComplete(progressStore.currentRoundIndex) {
            handleRoundCompletion(for: progressStore.currentRoundIndex)
        }
    }

    private func transitionToCard(_ card: TemperatureCard) {
        lastCardID = card.id
        phase = .playing(card)
    }

    private func handleRoundCompletion(for roundIndex: Int) {
        let nextRound = roundIndex + 1
        if nextRound < TemperatureCurriculum.rounds.count {
            progressStore.advanceToNextRoundIfNeeded()
            progressStore.unmarkTipSeen(forRound: nextRound)
            lastCardID = nil
            showTip(for: nextRound)
        } else {
            phase = .moduleComplete
        }
    }

    private func showTip(for roundIndex: Int) {
        phase = .showingTip(
            roundIndex: roundIndex,
            tips: TemperatureCurriculum.tips(forRound: roundIndex)
        )
    }

    private func selectNextCard(excluding excludedID: String? = nil) -> TemperatureCard? {
        let currentRoundIndex = progressStore.currentRoundIndex
        let currentCards = progressStore.currentSubRoundCards()
        var unlearnedCurrent = currentCards.filter { !progressStore.progress(for: $0).isLearned }

        let avoidID = excludedID ?? lastCardID
        if let avoidID {
            let withoutExcluded = unlearnedCurrent.filter { $0.id != avoidID }
            if !withoutExcluded.isEmpty {
                unlearnedCurrent = withoutExcluded
            }
        }

        guard !unlearnedCurrent.isEmpty else { return nil }

        var pool: [(card: TemperatureCard, weight: Int)] = []

        for card in unlearnedCurrent where card.id != avoidID {
            let progress = progressStore.progress(for: card)
            let weight: Int
            if progress.totalIncorrect > 0 && progress.consecutiveCorrect == 0 {
                weight = TemperatureGameConstants.strugglingCardWeight
            } else if progress.consecutiveCorrect > 0 {
                weight = TemperatureGameConstants.partialProgressWeight
            } else {
                weight = TemperatureGameConstants.currentRoundCardWeight
            }
            pool.append((card, weight))
        }

        if pool.isEmpty {
            pool = unlearnedCurrent.map { ($0, TemperatureGameConstants.currentRoundCardWeight) }
        }

        // Review cards from earlier sub-rounds/rounds in the mixed sub-round only.
        if progressStore.currentSubRoundIndex == 2 {
            let reviewCards = TemperatureCurriculum.allCards.filter { reviewCard in
                (reviewCard.roundIndex < currentRoundIndex
                    || (reviewCard.roundIndex == currentRoundIndex && isEarlierSubRound(reviewCard)))
                    && progressStore.progress(for: reviewCard).isLearned
                    && reviewCard.id != avoidID
            }
            for card in reviewCards {
                pool.append((card, TemperatureGameConstants.reviewCardWeight))
            }
        }

        return weightedRandom(from: pool)
    }

    private func isEarlierSubRound(_ card: TemperatureCard) -> Bool {
        guard card.roundIndex == progressStore.currentRoundIndex else { return false }
        switch card.direction {
        case .celsiusToFahrenheit:
            return progressStore.currentSubRoundIndex > 0
        case .fahrenheitToCelsius:
            return progressStore.currentSubRoundIndex > 1
        }
    }

    private func weightedRandom(from pool: [(card: TemperatureCard, weight: Int)]) -> TemperatureCard? {
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

extension TemperatureGameViewModel {
    static func multipleChoiceOptions(for card: TemperatureCard) -> [Int] {
        let correct = card.correctAnswer
        let bounds = card.answerRange
        let tolerance = TemperatureGameConstants.toleranceDegrees
        var distractors = Set<Int>()

        let offsets = [4, 6, 8, 10, 12, 15, 18, -4, -6, -8, -10, -12, -15, -18, 22, -22, 28, -28]
        for offset in offsets {
            let candidate = correct + offset
            if isValidDistractor(candidate, correct: correct, bounds: bounds, tolerance: tolerance) {
                distractors.insert(candidate)
            }
            if distractors.count == 3 { break }
        }

        var step = tolerance + 4
        while distractors.count < 3 {
            for delta in [step, -step] {
                let candidate = correct + delta
                if isValidDistractor(candidate, correct: correct, bounds: bounds, tolerance: tolerance) {
                    distractors.insert(candidate)
                }
            }
            step += 4
            if step > 40 { break }
        }

        while distractors.count < 3 {
            let candidate = Int.random(in: bounds)
            if isValidDistractor(candidate, correct: correct, bounds: bounds, tolerance: tolerance) {
                distractors.insert(candidate)
            }
        }

        return (Array(distractors.prefix(3)) + [correct]).shuffled()
    }

    private static func isValidDistractor(
        _ candidate: Int,
        correct: Int,
        bounds: ClosedRange<Int>,
        tolerance: Int
    ) -> Bool {
        bounds.contains(candidate)
            && candidate != correct
            && abs(candidate - correct) > tolerance
    }
}
