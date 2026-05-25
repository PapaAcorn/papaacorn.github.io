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
    case correct
    case incorrect(correctFahrenheit: Int)
}

@Observable
@MainActor
final class TemperatureGameViewModel {
    let progressStore: TemperatureProgressStore

    private(set) var phase: TemperatureGamePhase = .playing(TemperatureCurriculum.rounds[0].cards[0]) // overwritten in init
    private(set) var feedback: AnswerFeedback = .none
    private(set) var isSubmitting = false

    init(progressStore: TemperatureProgressStore) {
        self.progressStore = progressStore
        resumeFromSavedState()
    }

    var currentRound: TemperatureRound {
        TemperatureCurriculum.rounds[progressStore.currentRoundIndex]
    }

    var roundProgressText: String {
        let learned = progressStore.learnedCardCount(in: progressStore.currentRoundIndex)
        let total = currentRound.cards.count
        return "\(learned)/\(total) learned"
    }

    func resumeFromSavedState() {
        if progressStore.isModuleComplete {
            phase = .moduleComplete
            return
        }

        if progressStore.shouldShowTipBeforeRound(progressStore.currentRoundIndex) {
            showTip(for: progressStore.currentRoundIndex)
            return
        }

        if progressStore.isRoundComplete(progressStore.currentRoundIndex) {
            handleRoundCompletion(for: progressStore.currentRoundIndex)
            return
        }

        if let nextCard = selectNextCard() {
            phase = .playing(nextCard)
        }
    }

    func submitSliderAnswer(guess: Int, for card: TemperatureCard) {
        let correct = TemperatureConversion.isWithinTolerance(
            guess: guess,
            target: card.correctFahrenheit,
            tolerance: TemperatureGameConstants.sliderToleranceFahrenheit
        )
        submitAnswer(correct: correct, for: card)
    }

    func submitMultipleChoice(guess: Int, for card: TemperatureCard) {
        let correct = TemperatureConversion.isWithinTolerance(
            guess: guess,
            target: card.correctFahrenheit,
            tolerance: TemperatureGameConstants.multipleChoiceToleranceFahrenheit
        )
        submitAnswer(correct: correct, for: card)
    }

    func dismissTipAndContinue() {
        guard case .showingTip(let roundIndex, _) = phase else { return }
        progressStore.markTipSeen(forRound: roundIndex)

        if progressStore.isRoundComplete(roundIndex - 1) == false && roundIndex == progressStore.currentRoundIndex {
            // Tip shown before entering this round — start playing.
        }

        if let card = selectNextCard() {
            phase = .playing(card)
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
        resumeFromSavedState()
    }

    // MARK: - Private

    private func submitAnswer(correct: Bool, for card: TemperatureCard) {
        guard !isSubmitting else { return }
        isSubmitting = true
        progressStore.recordAnswer(for: card, correct: correct)
        feedback = correct ? .correct : .incorrect(correctFahrenheit: card.correctFahrenheit)

        Task {
            try? await Task.sleep(for: .milliseconds(correct ? 900 : 1600))
            feedback = .none
            isSubmitting = false

            if progressStore.isRoundComplete(card.roundIndex) {
                handleRoundCompletion(for: card.roundIndex)
            } else if let next = selectNextCard(excluding: correct ? nil : card.id) {
                phase = .playing(next)
            }
        }
    }

    private func handleRoundCompletion(for roundIndex: Int) {
        let nextRound = roundIndex + 1
        if nextRound < TemperatureCurriculum.rounds.count {
            progressStore.advanceToNextRoundIfNeeded()
            // Always show tips between rounds, even if seen before on a prior session.
            progressStore.unmarkTipSeen(forRound: nextRound)
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
        let currentCards = TemperatureCurriculum.cards(forRound: currentRoundIndex)
        var unlearnedCurrent = currentCards.filter { !progressStore.progress(for: $0).isLearned }

        if let excludedID {
            let withoutExcluded = unlearnedCurrent.filter { $0.id != excludedID }
            if !withoutExcluded.isEmpty {
                unlearnedCurrent = withoutExcluded
            }
        }

        guard !unlearnedCurrent.isEmpty else { return nil }

        var pool: [(card: TemperatureCard, weight: Int)] = []

        for card in unlearnedCurrent {
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

        // Sprinkle in learned cards from earlier rounds for retention.
        let reviewCards = TemperatureCurriculum.allCards.filter { card in
            card.roundIndex < currentRoundIndex && progressStore.progress(for: card).isLearned
        }
        for card in reviewCards {
            pool.append((card, TemperatureGameConstants.reviewCardWeight))
        }

        return weightedRandom(from: pool)
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
        let correct = card.correctFahrenheit
        let bounds = TemperatureGameConstants.fahrenheitMin...TemperatureGameConstants.fahrenheitMax
        var distractors = Set<Int>()

        let offsets = [4, 6, 8, 10, 12, 15, 18, -4, -6, -8, -10, -12, -15, -18, 22, -22, 28, -28]
        for offset in offsets {
            let candidate = correct + offset
            if candidate != correct, bounds.contains(candidate) {
                distractors.insert(candidate)
            }
            if distractors.count == 3 { break }
        }

        var step = 20
        while distractors.count < 3 {
            for delta in [step, -step] {
                let candidate = correct + delta
                if candidate != correct, bounds.contains(candidate) {
                    distractors.insert(candidate)
                }
            }
            step += 10
            if step > 60 { break }
        }

        while distractors.count < 3 {
            let candidate = Int.random(in: bounds)
            if candidate != correct {
                distractors.insert(candidate)
            }
        }

        return (Array(distractors.prefix(3)) + [correct]).shuffled()
    }
}
