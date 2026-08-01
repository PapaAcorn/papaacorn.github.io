//
//  RoadGameViewModel.swift
//  Metricize
//

import Foundation
import Observation

enum RoadGamePhase: Equatable {
    case playing(RoadCard)
    case showingTip(roundIndex: Int, tips: [String])
    case showingBatchReview(roundIndex: Int, subRoundIndex: Int, items: [ConversionReviewItem])
    case finalExamResult(passed: Bool, correct: Int, total: Int)
    case roundComplete(roundIndex: Int)
    case moduleComplete
}

enum RoadAnswerFeedback: Equatable {
    case none
    case exact(answerLabel: String, card: RoadCard)
    case incorrect(correctLabel: String, card: RoadCard)
}

@Observable
@MainActor
final class RoadGameViewModel {
    let progressStore: RoadProgressStore
    let settings: AppSettingsStore

    private(set) var phase: RoadGamePhase = .playing(RoadCurriculum.rounds[0].cards[0])
    private(set) var feedback: RoadAnswerFeedback = .none
    private(set) var isSubmitting = false
    private(set) var activeChoiceLabels: [String]?
    private var activeCorrectChoiceIndex = 0
    private var lastCardID: String?

    init(progressStore: RoadProgressStore, settings: AppSettingsStore) {
        self.progressStore = progressStore
        self.settings = settings
        resumeFromSavedState()
    }

    private var isTakingFinalExam: Bool {
        progressStore.isActiveFinalExamSession
    }

    var currentRound: RoadRound {
        RoadCurriculum.rounds[progressStore.currentRoundIndex]
    }

    func resumeFromSavedState() {
        lastCardID = nil
        progressStore.normalizePosition()

        if progressStore.isModuleComplete {
            phase = .moduleComplete
            return
        }

        if progressStore.isFinalExamRound(progressStore.currentRoundIndex) {
            resumeFinalExam()
            return
        }

        enterCurrentSubRound()
    }

    func submitMultipleChoice(guess: Int, for card: RoadCard) {
        submitAnswer(guess: guess, for: card)
    }

    func dismissBatchReviewAndContinue() {
        guard case .showingBatchReview(let roundIndex, let subRoundIndex, _) = phase else { return }
        progressStore.acknowledgeBatchReview(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        lastCardID = nil
        beginPracticingCurrentSubRound()
    }

    func dismissTipAndContinue() {
        guard case .showingTip(let roundIndex, _) = phase else { return }
        progressStore.markTipSeen(forRound: roundIndex)

        if progressStore.isFinalExamRound(roundIndex) {
            beginFinalExam()
            return
        }

        if presentBatchReviewIfNeeded() {
            return
        }

        beginPracticingCurrentSubRound()
    }

    func continueAfterRoundComplete() {
        guard case .roundComplete = phase else { return }
        resumeFromSavedState()
    }

    func retryFinalExam() {
        feedback = .none
        lastCardID = nil
        progressStore.clearFinalExamSession()
        beginFinalExam()
    }

    func acknowledgeExamPass() {
        phase = .moduleComplete
    }

    func reviewEarlierRoundsAfterExam() {
        feedback = .none
        lastCardID = nil
        progressStore.repositionForLearningReview()
        resumeFromSavedState()
    }

    func resetModule() {
        progressStore.resetProgress()
        feedback = .none
        lastCardID = nil
        resumeFromSavedState()
    }

    func redoSubRound(roundIndex: Int, subRoundIndex: Int) {
        guard !progressStore.isFinalExamRound(roundIndex) else { return }
        feedback = .none
        lastCardID = nil
        activeChoiceLabels = nil
        progressStore.prepareToRedoSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        enterCurrentSubRound()
    }

    func redoFinalExam() {
        guard progressStore.canAccessFinalExam else { return }
        feedback = .none
        lastCardID = nil
        activeChoiceLabels = nil
        progressStore.prepareToRedoFinalExam()
        beginFinalExam()
    }

    // MARK: - Private

    private func resumeFinalExam() {
        if progressStore.shouldShowTipBeforeRound(RoadGameConstants.finalExamRoundIndex) {
            showTip(for: RoadGameConstants.finalExamRoundIndex)
            return
        }

        if let session = progressStore.finalExamSession {
            if session.isComplete {
                presentFinalExamResult(from: session)
            } else if progressStore.currentExamCard() != nil {
                showCurrentExamCard()
            } else if session.questions.isEmpty {
                beginFinalExam()
            } else {
                presentFinalExamResult(from: session)
            }
            return
        }

        if progressStore.areLearningRoundsComplete() {
            beginFinalExam()
        }
    }

    private func beginFinalExam() {
        let questions = RoadCurriculum.generateFinalExamQuestions()
        progressStore.startFinalExamSession(questions)
        showCurrentExamCard()
    }

    private func submitAnswer(guess: Int, for card: RoadCard) {
        guard !isSubmitting else { return }
        isSubmitting = true

        if isTakingFinalExam {
            submitExamAnswer(guess: guess, for: card)
            return
        }

        let result = RoadConversion.evaluate(guess: guess, correctIndex: activeCorrectChoiceIndex)
        let isCorrect = result == .exact

        progressStore.recordAnswer(for: card, correct: isCorrect)
        presentFeedback(result: result, card: card) {
            self.continueAfterLearningAnswer(for: card)
        }
    }

    private func submitExamAnswer(guess: Int, for card: RoadCard) {
        let activeCard = progressStore.currentExamCard() ?? card
        let result = RoadConversion.evaluate(guess: guess, correctIndex: activeCorrectChoiceIndex)
        let isCorrect = result == .exact

        progressStore.recordFinalExamAnswer(correct: isCorrect)
        presentFeedback(result: result, card: activeCard) {
            self.continueAfterExamAnswer()
        }
    }

    private func presentFeedback(
        result: RoadConversion.AnswerResult,
        card: RoadCard,
        completion: @escaping () -> Void
    ) {
        let correctLabel = card.answerLabel
        switch result {
        case .exact:
            feedback = .exact(answerLabel: correctLabel, card: card)
        case .incorrect:
            feedback = .incorrect(correctLabel: correctLabel, card: card)
        }

        let isCorrect = result == .exact
        Task {
            try? await Task.sleep(for: .milliseconds(isCorrect ? 1800 : 3200))
            feedback = .none
            isSubmitting = false
            completion()
        }
    }

    private func continueAfterLearningAnswer(for card: RoadCard) {
        let roundIndex = progressStore.currentRoundIndex
        let subRoundIndex = progressStore.currentSubRoundIndex

        if progressStore.isSubRoundComplete(roundIndex, subRoundIndex: subRoundIndex) {
            advanceFromCompletedSubRound()
        } else {
            progressStore.releaseNextBatchIfCurrentSetComplete(
                roundIndex: roundIndex,
                subRoundIndex: subRoundIndex
            )
            if presentBatchReviewIfNeeded() {
                return
            }
            if let next = selectNextCard() {
                transitionToCard(next)
            }
        }
    }

    private func continueAfterExamAnswer() {
        guard let session = progressStore.finalExamSession else { return }
        if session.isComplete {
            presentFinalExamResult(from: session)
        } else {
            showCurrentExamCard()
        }
    }

    private func showCurrentExamCard() {
        guard let card = progressStore.currentExamCard() else { return }
        lastCardID = nil
        activeChoiceLabels = nil
        phase = .playing(card)
    }

    private func presentFinalExamResult(from session: RoadFinalExamSession) {
        let passed = session.correctCount >= RoadGameConstants.examPassCorrectCount
        if passed {
            progressStore.markFinalExamPassed()
        } else {
            progressStore.clearFinalExamSession()
        }
        phase = .finalExamResult(
            passed: passed,
            correct: session.correctCount,
            total: session.totalQuestions
        )
    }

    private func advanceFromCompletedSubRound() {
        if progressStore.advanceSubRoundIfNeeded() {
            lastCardID = nil
            enterCurrentSubRound()
            return
        }

        if progressStore.isRoundComplete(progressStore.currentRoundIndex) {
            handleRoundCompletion(for: progressStore.currentRoundIndex)
        }
    }

    private func beginPracticingCurrentSubRound() {
        let roundIndex = progressStore.currentRoundIndex
        let subRoundIndex = progressStore.currentSubRoundIndex

        if progressStore.isSubRoundComplete(roundIndex, subRoundIndex: subRoundIndex) {
            advanceFromCompletedSubRound()
            return
        }

        if let nextCard = selectNextCard() {
            transitionToCard(nextCard)
        } else if progressStore.isModuleComplete {
            phase = .moduleComplete
        }
    }

    private func enterCurrentSubRound() {
        if isTakingFinalExam {
            showCurrentExamCard()
            return
        }

        let roundIndex = progressStore.currentRoundIndex
        let subRoundIndex = progressStore.currentSubRoundIndex

        if subRoundIndex == 0,
           progressStore.shouldShowTipBeforeRound(roundIndex) {
            showTip(for: roundIndex)
            return
        }

        if presentBatchReviewIfNeeded() {
            return
        }

        if progressStore.isSubRoundComplete(roundIndex, subRoundIndex: subRoundIndex) {
            advanceFromCompletedSubRound()
            return
        }

        if let nextCard = selectNextCard() {
            transitionToCard(nextCard)
        }
    }

    @discardableResult
    private func presentBatchReviewIfNeeded() -> Bool {
        let roundIndex = progressStore.currentRoundIndex
        let subRoundIndex = progressStore.currentSubRoundIndex
        guard progressStore.shouldShowBatchReview(roundIndex: roundIndex, subRoundIndex: subRoundIndex) else {
            return false
        }

        if progressStore.pendingBatchReviewKey == nil {
            progressStore.markPendingBatchReview(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        }

        let cards = progressStore.cardsForBatchReview(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        guard !cards.isEmpty else { return false }

        phase = .showingBatchReview(
            roundIndex: roundIndex,
            subRoundIndex: subRoundIndex,
            items: RoadCurriculum.batchReviewItems(for: cards)
        )
        return true
    }

    private func transitionToCard(_ card: RoadCard) {
        if isTakingFinalExam {
            showCurrentExamCard()
            return
        }

        let roundIndex = progressStore.currentRoundIndex
        let subRoundIndex = progressStore.currentSubRoundIndex
        if progressStore.shouldShowBatchReview(roundIndex: roundIndex, subRoundIndex: subRoundIndex) {
            presentBatchReviewIfNeeded()
            return
        }

        lastCardID = card.id
        phase = .playing(card)
    }

    private func handleRoundCompletion(for roundIndex: Int) {
        let nextRound = roundIndex + 1
        if nextRound < RoadCurriculum.rounds.count {
            progressStore.advanceToNextRoundIfNeeded()
            progressStore.unmarkTipSeen(forRound: nextRound)
            lastCardID = nil
            if RoadCurriculum.rounds[nextRound].isFinalExam {
                showTip(for: nextRound)
            } else {
                enterCurrentSubRound()
            }
        } else {
            phase = .moduleComplete
        }
    }

    private func showTip(for roundIndex: Int) {
        phase = .showingTip(
            roundIndex: roundIndex,
            tips: RoadCurriculum.tips(forRound: roundIndex)
        )
    }

    private func selectNextCard(excluding excludedID: String? = nil) -> RoadCard? {
        let currentRoundIndex = progressStore.currentRoundIndex
        let currentCards = progressStore.currentSubRoundCards()
        var unlearnedCurrent = currentCards.filter { !progressStore.progress(for: $0).isLearned }

        if progressStore.currentSubRoundIndex == RoadGameConstants.mixedSubRoundIndex {
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

        var pool: [(card: RoadCard, weight: Int)] = []

        for card in unlearnedCurrent where card.id != avoidID {
            let progress = progressStore.progress(for: card)
            let weight: Int
            if progress.totalIncorrect > 0 && progress.consecutiveCorrect == 0 {
                weight = RoadGameConstants.strugglingCardWeight
            } else if progress.consecutiveCorrect > 0 {
                weight = RoadGameConstants.partialProgressWeight
            } else {
                weight = RoadGameConstants.currentRoundCardWeight
            }
            pool.append((card, weight))
        }

        if pool.isEmpty {
            pool = unlearnedCurrent.map { ($0, RoadGameConstants.currentRoundCardWeight) }
        }

        if progressStore.currentSubRoundIndex == RoadGameConstants.mixedSubRoundIndex {
            let reviewCards = RoadCurriculum.allCards.filter { reviewCard in
                (reviewCard.roundIndex < currentRoundIndex
                    || (reviewCard.roundIndex == currentRoundIndex && isEarlierSubRound(reviewCard)))
                    && progressStore.progress(for: reviewCard).isLearned
                    && reviewCard.id != avoidID
            }
            for card in reviewCards {
                pool.append((card, RoadGameConstants.reviewCardWeight))
            }
        }

        return weightedRandom(from: pool)
    }

    private func isEarlierSubRound(_ card: RoadCard) -> Bool {
        guard card.roundIndex == progressStore.currentRoundIndex else { return false }
        switch card.direction {
        case .metricToImperial:
            return progressStore.currentSubRoundIndex > 0
        case .imperialToMetric:
            return progressStore.currentSubRoundIndex > 1
        }
    }

    private func weightedRandom(from pool: [(card: RoadCard, weight: Int)]) -> RoadCard? {
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

extension RoadGameViewModel {
    func multipleChoiceOptions(for card: RoadCard) -> [Int] {
        let answerLabel = card.answerLabel
        let pool = RoadConversion.distractorLabels(for: card).filter { $0 != answerLabel }
        let distractors = Array(Set(pool)).shuffled().prefix(3)
        var labels = (distractors + [answerLabel]).shuffled()
        if labels.count < 4 {
            for candidate in pool where labels.count < 4 && !labels.contains(candidate) {
                labels.append(candidate)
            }
        }
        activeChoiceLabels = labels
        activeCorrectChoiceIndex = labels.firstIndex(of: answerLabel) ?? 0
        return Array(labels.indices)
    }
}
