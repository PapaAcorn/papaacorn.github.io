//
//  TemperatureGameViewModel.swift
//  Metricize
//

import Foundation
import Observation

enum TemperatureGamePhase: Equatable {
    case playing(TemperatureCard)
    case showingTip(roundIndex: Int, tips: [String])
    case showingSubRoundReview(roundIndex: Int, subRoundIndex: Int, items: [ConversionReviewItem])
    case finalExamResult(passed: Bool, correct: Int, total: Int)
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
    let settings: AppSettingsStore

    private(set) var phase: TemperatureGamePhase = .playing(TemperatureCurriculum.rounds[0].cards[0])
    private(set) var feedback: AnswerFeedback = .none
    private(set) var isSubmitting = false
    private var lastCardID: String?

    init(progressStore: TemperatureProgressStore, settings: AppSettingsStore) {
        self.progressStore = progressStore
        self.settings = settings
        resumeFromSavedState()
    }

    private var accuracyTolerance: Int {
        settings.accuracyToleranceDegrees
    }

    private var isTakingFinalExam: Bool {
        progressStore.isActiveFinalExamSession
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

        if progressStore.isFinalExamRound(progressStore.currentRoundIndex) {
            resumeFinalExam()
            return
        }

        enterCurrentSubRound()
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

        if progressStore.isFinalExamRound(roundIndex) {
            beginFinalExam()
            return
        }

        enterCurrentSubRound()
    }

    func dismissSubRoundReviewAndContinue() {
        guard case .showingSubRoundReview(let roundIndex, let subRoundIndex, _) = phase else { return }
        progressStore.acknowledgeSubRoundPreview(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        lastCardID = nil
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
        progressStore.prepareToRedoSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        enterCurrentSubRound()
    }

    func redoFinalExam() {
        guard progressStore.canAccessFinalExam else { return }
        feedback = .none
        lastCardID = nil
        progressStore.prepareToRedoFinalExam()
        beginFinalExam()
    }

    // MARK: - Private

    private func resumeFinalExam() {
        if progressStore.shouldShowTipBeforeRound(TemperatureGameConstants.finalExamRoundIndex) {
            showTip(for: TemperatureGameConstants.finalExamRoundIndex)
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
        let questions = TemperatureCurriculum.generateFinalExamQuestions()
        progressStore.startFinalExamSession(questions)
        showCurrentExamCard()
    }

    private func submitAnswer(guess: Int, for card: TemperatureCard) {
        guard !isSubmitting else { return }
        isSubmitting = true

        if isTakingFinalExam {
            submitExamAnswer(guess: guess, for: card)
            return
        }

        let target = card.correctAnswer
        let result = TemperatureConversion.evaluate(guess: guess, target: target, tolerance: accuracyTolerance)
        let isCorrect = result != .incorrect
        progressStore.recordAnswer(for: card, correct: isCorrect)
        presentFeedback(result: result, target: target, unit: card.answerUnit) {
            self.continueAfterLearningAnswer(for: card)
        }
    }

    private func submitExamAnswer(guess: Int, for card: TemperatureCard) {
        let activeCard = progressStore.currentExamCard() ?? card
        let target = activeCard.correctAnswer
        let result = TemperatureConversion.evaluate(guess: guess, target: target, tolerance: accuracyTolerance)
        let isCorrect = result != .incorrect
        progressStore.recordFinalExamAnswer(correct: isCorrect)
        presentFeedback(result: result, target: target, unit: activeCard.answerUnit) {
            self.continueAfterExamAnswer()
        }
    }

    private func presentFeedback(
        result: TemperatureConversion.AnswerResult,
        target: Int,
        unit: String,
        completion: @escaping () -> Void
    ) {
        switch result {
        case .exact:
            feedback = .exact(answer: target, unit: unit)
        case .closeEnough:
            feedback = .closeEnough(answer: target, unit: unit)
        case .incorrect:
            feedback = .incorrect(correctAnswer: target, unit: unit)
        }

        let isCorrect = result != .incorrect
        Task {
            try? await Task.sleep(for: .milliseconds(isCorrect ? 1800 : 3200))
            feedback = .none
            isSubmitting = false
            completion()
        }
    }

    private func continueAfterLearningAnswer(for card: TemperatureCard) {
        if progressStore.isSubRoundComplete(
            progressStore.currentRoundIndex,
            subRoundIndex: progressStore.currentSubRoundIndex
        ) {
            advanceFromCompletedSubRound()
        } else if let next = selectNextCard() {
            transitionToCard(next)
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
        phase = .playing(card)
    }

    private func presentFinalExamResult(from session: FinalExamSession) {
        let passed = session.correctCount >= TemperatureGameConstants.examPassCorrectCount
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

        if presentSubRoundReviewIfNeeded() {
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

    private func transitionToCard(_ card: TemperatureCard) {
        if isTakingFinalExam {
            showCurrentExamCard()
            return
        }

        let roundIndex = progressStore.currentRoundIndex
        let subRoundIndex = progressStore.currentSubRoundIndex
        if progressStore.shouldShowSubRoundPreview(roundIndex: roundIndex, subRoundIndex: subRoundIndex) {
            presentSubRoundReviewIfNeeded()
            return
        }

        lastCardID = card.id
        phase = .playing(card)
    }

    private func handleRoundCompletion(for roundIndex: Int) {
        let nextRound = roundIndex + 1
        if nextRound < TemperatureCurriculum.rounds.count {
            progressStore.advanceToNextRoundIfNeeded()
            progressStore.unmarkTipSeen(forRound: nextRound)
            progressStore.unmarkSubRoundPreview(roundIndex: nextRound, subRoundIndex: 0)
            lastCardID = nil
            if TemperatureCurriculum.rounds[nextRound].isFinalExam {
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
            tips: TemperatureCurriculum.tips(forRound: roundIndex)
        )
    }

    @discardableResult
    private func presentSubRoundReviewIfNeeded() -> Bool {
        let roundIndex = progressStore.currentRoundIndex
        let subRoundIndex = progressStore.currentSubRoundIndex
        guard progressStore.shouldShowSubRoundPreview(roundIndex: roundIndex, subRoundIndex: subRoundIndex) else {
            return false
        }

        let items = TemperatureCurriculum.subRoundReviewItems(
            forRound: roundIndex,
            subRoundIndex: subRoundIndex
        )
        guard !items.isEmpty else { return false }

        phase = .showingSubRoundReview(roundIndex: roundIndex, subRoundIndex: subRoundIndex, items: items)
        return true
    }

    private func selectNextCard(excluding excludedID: String? = nil) -> TemperatureCard? {
        let currentRoundIndex = progressStore.currentRoundIndex
        let currentCards = progressStore.currentSubRoundCards()
        var unlearnedCurrent = currentCards.filter { !progressStore.progress(for: $0).isLearned }

        if progressStore.currentSubRoundIndex == TemperatureGameConstants.mixedSubRoundIndex {
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

        if progressStore.currentSubRoundIndex == TemperatureGameConstants.mixedSubRoundIndex {
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
    func multipleChoiceOptions(for card: TemperatureCard) -> [Int] {
        let correct = card.correctAnswer
        let bounds = card.answerRange
        let tolerance = accuracyTolerance
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

    private func isValidDistractor(
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
