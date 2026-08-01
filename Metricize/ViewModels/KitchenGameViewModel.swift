//
//  KitchenGameViewModel.swift
//  Metricize
//

import Foundation
import Observation

enum KitchenGamePhase: Equatable {
    case playing(KitchenCard)
    case showingTip(roundIndex: Int, tips: [String])
    case showingBatchReview(roundIndex: Int, subRoundIndex: Int, items: [ConversionReviewItem])
    case finalExamResult(passed: Bool, correct: Int, total: Int)
    case roundComplete(roundIndex: Int)
    case moduleComplete
}

enum KitchenAnswerFeedback: Equatable {
    case none
    case exact(answer: Int, unit: String, card: KitchenCard)
    case closeEnough(answer: Int, unit: String, card: KitchenCard)
    case incorrect(correctAnswer: Int, unit: String, card: KitchenCard)
}

@Observable
@MainActor
final class KitchenGameViewModel {
    let progressStore: KitchenProgressStore
    let settings: AppSettingsStore

    private(set) var phase: KitchenGamePhase = .playing(KitchenCurriculum.rounds[0].cards[0])
    private(set) var feedback: KitchenAnswerFeedback = .none
    private(set) var isSubmitting = false
    private(set) var activeChoiceLabels: [String]?
    private var activeCorrectChoiceIndex = 0
    private var lastCardID: String?

    init(progressStore: KitchenProgressStore, settings: AppSettingsStore) {
        self.progressStore = progressStore
        self.settings = settings
        resumeFromSavedState()
    }

    private var accuracyTolerance: Int { 0 }

    private var isTakingFinalExam: Bool {
        progressStore.isActiveFinalExamSession
    }

    var currentRound: KitchenRound {
        KitchenCurriculum.rounds[progressStore.currentRoundIndex]
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

    func submitSliderAnswer(guess: Int, for card: KitchenCard) {
        submitAnswer(guess: guess, for: card)
    }

    func submitMultipleChoice(guess: Int, for card: KitchenCard) {
        submitAnswer(guess: guess, for: card)
    }

    func submitBooleanChoice(isYes: Bool, for card: KitchenCard) {
        submitAnswer(guess: isYes ? 1 : 0, for: card)
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
        if progressStore.shouldShowTipBeforeRound(KitchenGameConstants.finalExamRoundIndex) {
            showTip(for: KitchenGameConstants.finalExamRoundIndex)
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
        let questions = KitchenCurriculum.generateFinalExamQuestions()
        progressStore.startFinalExamSession(questions)
        showCurrentExamCard()
    }

    private func submitAnswer(guess: Int, for card: KitchenCard) {
        guard !isSubmitting else { return }
        isSubmitting = true

        if isTakingFinalExam {
            submitExamAnswer(guess: guess, for: card)
            return
        }

        let result: KitchenConversion.AnswerResult
        if card.usesLabeledChoices {
            result = guess == activeCorrectChoiceIndex ? .exact : .incorrect
        } else {
            let tolerance = KitchenConversion.effectiveTolerance(for: card)
            result = KitchenConversion.evaluate(guess: guess, for: card, tolerance: tolerance)
        }
        let isCorrect = result != .incorrect

        progressStore.recordAnswer(for: card, correct: isCorrect)
        presentFeedback(result: result, card: card) {
            self.continueAfterLearningAnswer(for: card)
        }
    }

    private func submitExamAnswer(guess: Int, for card: KitchenCard) {
        let activeCard = progressStore.currentExamCard() ?? card
        let result: KitchenConversion.AnswerResult
        if activeCard.usesLabeledChoices {
            result = guess == activeCorrectChoiceIndex ? .exact : .incorrect
        } else {
            let tolerance = KitchenConversion.effectiveTolerance(for: activeCard)
            result = KitchenConversion.evaluate(guess: guess, for: activeCard, tolerance: tolerance)
        }
        let isCorrect = result != .incorrect

        progressStore.recordFinalExamAnswer(correct: isCorrect)
        presentFeedback(result: result, card: activeCard) {
            self.continueAfterExamAnswer()
        }
    }

    private func presentFeedback(
        result: KitchenConversion.AnswerResult,
        card: KitchenCard,
        completion: @escaping () -> Void
    ) {
        let target = card.usesLabeledChoices ? activeCorrectChoiceIndex : card.correctAnswer
        let unit = card.answerUnit
        switch result {
        case .exact:
            feedback = .exact(answer: target, unit: unit, card: card)
        case .closeEnough:
            feedback = .closeEnough(answer: target, unit: unit, card: card)
        case .incorrect:
            feedback = .incorrect(correctAnswer: target, unit: unit, card: card)
        }

        let isCorrect = result != .incorrect
        Task {
            try? await Task.sleep(for: .milliseconds(isCorrect ? 1800 : 3200))
            feedback = .none
            isSubmitting = false
            completion()
        }
    }

    private func continueAfterLearningAnswer(for card: KitchenCard) {
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

    private func presentFinalExamResult(from session: KitchenFinalExamSession) {
        let passed = session.correctCount >= KitchenGameConstants.examPassCorrectCount
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
            items: KitchenCurriculum.batchReviewItems(for: cards)
        )
        return true
    }

    private func transitionToCard(_ card: KitchenCard) {
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
        if nextRound < KitchenCurriculum.rounds.count {
            progressStore.advanceToNextRoundIfNeeded()
            progressStore.unmarkTipSeen(forRound: nextRound)
            lastCardID = nil
            if KitchenCurriculum.rounds[nextRound].isFinalExam {
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
            tips: KitchenCurriculum.tips(forRound: roundIndex)
        )
    }

    private func selectNextCard(excluding excludedID: String? = nil) -> KitchenCard? {
        let currentRoundIndex = progressStore.currentRoundIndex
        let currentCards = progressStore.currentSubRoundCards()
        var unlearnedCurrent = currentCards.filter { !progressStore.progress(for: $0).isLearned }

        if progressStore.currentSubRoundIndex == KitchenGameConstants.mixedSubRoundIndex {
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

        var pool: [(card: KitchenCard, weight: Int)] = []

        for card in unlearnedCurrent where card.id != avoidID {
            let progress = progressStore.progress(for: card)
            let weight: Int
            if progress.totalIncorrect > 0 && progress.consecutiveCorrect == 0 {
                weight = KitchenGameConstants.strugglingCardWeight
            } else if progress.consecutiveCorrect > 0 {
                weight = KitchenGameConstants.partialProgressWeight
            } else {
                weight = KitchenGameConstants.currentRoundCardWeight
            }
            pool.append((card, weight))
        }

        if pool.isEmpty {
            pool = unlearnedCurrent.map { ($0, KitchenGameConstants.currentRoundCardWeight) }
        }

        if progressStore.currentSubRoundIndex == KitchenGameConstants.mixedSubRoundIndex {
            let reviewCards = KitchenCurriculum.allCards.filter { reviewCard in
                (reviewCard.roundIndex < currentRoundIndex
                    || (reviewCard.roundIndex == currentRoundIndex && isEarlierSubRound(reviewCard)))
                    && progressStore.progress(for: reviewCard).isLearned
                    && reviewCard.id != avoidID
            }
            for card in reviewCards {
                pool.append((card, KitchenGameConstants.reviewCardWeight))
            }
        }

        return weightedRandom(from: pool)
    }

    private func isEarlierSubRound(_ card: KitchenCard) -> Bool {
        guard card.roundIndex == progressStore.currentRoundIndex else { return false }
        switch card.direction {
        case .imperialToMetric:
            return progressStore.currentSubRoundIndex > 0
        case .metricToImperial:
            return progressStore.currentSubRoundIndex > 1
        }
    }

    private func weightedRandom(from pool: [(card: KitchenCard, weight: Int)]) -> KitchenCard? {
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

extension KitchenGameViewModel {
    func multipleChoiceOptions(for card: KitchenCard) -> [Int] {
        if card.kind == .booleanComparison {
            activeChoiceLabels = nil
            activeCorrectChoiceIndex = card.correctAnswer
            return [0, 1].shuffled()
        }

        if card.kind == .panConcept, let choiceLabels = card.choiceLabels {
            let shuffled = choiceLabels.shuffled()
            let correctLabel = choiceLabels[card.correctAnswer]
            activeChoiceLabels = shuffled
            activeCorrectChoiceIndex = shuffled.firstIndex(of: correctLabel) ?? card.correctAnswer
            return Array(shuffled.indices)
        }

        if card.kind == .panSize, let answerLabel = card.answerLabel {
            let pool = KitchenConversion.panSizeDistractorLabels(for: card).filter { $0 != answerLabel }
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

        activeChoiceLabels = nil

        let correct = card.correctAnswer
        let bounds = card.answerRange
        let minSeparation = KitchenConversion.minimumDistractorSeparation(for: card)
        var distractors = Set<Int>()

        let anchorCandidates = KitchenConversion.distractorCandidates(for: card)
            .filter { candidate in
                isValidDistractor(
                    candidate,
                    correct: correct,
                    bounds: bounds,
                    minSeparation: minSeparation,
                    card: card
                )
            }
            .sorted { abs($0 - correct) > abs($1 - correct) }

        for candidate in anchorCandidates {
            distractors.insert(candidate)
            if distractors.count == 3 { break }
        }

        if card.requiresExactAnswer {
            for candidate in foodSafetyDistractors(for: card) {
                if isValidDistractor(
                    candidate,
                    correct: correct,
                    bounds: bounds,
                    minSeparation: minSeparation,
                    card: card
                ) {
                    distractors.insert(candidate)
                }
                if distractors.count == 3 { break }
            }
        }

        var step = max(minSeparation, 10)
        while distractors.count < 3 {
            for delta in [step, -step, step * 2, -step * 2] {
                let candidate = correct + delta
                if isValidDistractor(
                    candidate,
                    correct: correct,
                    bounds: bounds,
                    minSeparation: minSeparation,
                    card: card
                ) {
                    distractors.insert(candidate)
                }
            }
            step += minSeparation
            if step > 120 { break }
        }

        while distractors.count < 3 {
            let candidate = Int.random(in: bounds)
            if isValidDistractor(
                candidate,
                correct: correct,
                bounds: bounds,
                minSeparation: minSeparation,
                card: card
            ) {
                distractors.insert(candidate)
            }
        }

        let options = (Array(distractors.prefix(3)) + [correct]).shuffled()
        activeCorrectChoiceIndex = options.firstIndex(of: correct) ?? options.count - 1
        return options
    }

    private func foodSafetyDistractors(for card: KitchenCard) -> [Int] {
        // Keep distractors near but never below USDA minimums for the food type.
        let commonSafetyTemps = [145, 160, 165, 63, 71, 74]
        return commonSafetyTemps.filter { $0 != card.correctAnswer && $0 != card.alternateExactAnswer }
    }

    private func isValidDistractor(
        _ candidate: Int,
        correct: Int,
        bounds: ClosedRange<Int>,
        minSeparation: Int,
        card: KitchenCard
    ) -> Bool {
        guard bounds.contains(candidate), candidate != correct else { return false }
        guard abs(candidate - correct) >= minSeparation else { return false }

        if card.requiresExactAnswer {
            // Reject dangerously low temperatures for food safety questions.
            if candidate < correct { return false }
        }

        return true
    }
}
