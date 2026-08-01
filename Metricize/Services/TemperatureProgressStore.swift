//
//  TemperatureProgressStore.swift
//  Metricize
//

import Foundation

@Observable
final class TemperatureProgressStore {
    private let storageKey = "metricize.temperature.progress"
    private(set) var progressByCardID: [String: CardProgress] = [:]
    private(set) var currentRoundIndex: Int = 0
    private(set) var currentSubRoundIndex: Int = 0
    private(set) var hasSeenTipForRound: Set<Int> = []
    private(set) var previewedSubRoundKeys: Set<String> = []
    private(set) var hasPassedFinalExam: Bool = false
    private(set) var finalExamSession: FinalExamSession?

    init() {
        load()
        normalizePosition()
    }

    func progress(for card: TemperatureCard) -> CardProgress {
        progressByCardID[card.id] ?? CardProgress()
    }

    func recordAnswer(for card: TemperatureCard, correct: Bool) {
        var progress = progress(for: card)
        let inMixedPractice = currentSubRoundIndex == TemperatureGameConstants.mixedSubRoundIndex
            && !isFinalExamRound(currentRoundIndex)

        if correct {
            progress.consecutiveCorrect += 1
            progress.totalCorrect += 1
            if inMixedPractice {
                progress.mixedConsecutiveCorrect += 1
            }
        } else {
            progress.consecutiveCorrect = 0
            progress.totalIncorrect += 1
            if inMixedPractice {
                progress.mixedConsecutiveCorrect = 0
            }
        }
        progressByCardID[card.id] = progress
        save()
    }

    func recordFinalExamAnswer(correct: Bool) {
        guard var session = finalExamSession else { return }
        if correct {
            session.correctCount += 1
        }
        session.currentQuestionIndex += 1
        finalExamSession = session
        save()
    }

    func startFinalExamSession(_ questions: [TemperatureCard]) {
        finalExamSession = FinalExamSession(questions: questions)
        currentRoundIndex = TemperatureGameConstants.finalExamRoundIndex
        currentSubRoundIndex = 0
        save()
    }

    func clearFinalExamSession() {
        finalExamSession = nil
        save()
    }

    func repositionForLearningReview() {
        currentRoundIndex = 0
        currentSubRoundIndex = 0
        clearFinalExamSession()
        save()
    }

    func markFinalExamPassed() {
        hasPassedFinalExam = true
        clearFinalExamSession()
        save()
    }

    func cardsForSubRound(roundIndex: Int, subRoundIndex: Int) -> [TemperatureCard] {
        TemperatureCurriculum.cards(forRound: roundIndex, subRoundIndex: subRoundIndex)
    }

    func currentSubRoundCards() -> [TemperatureCard] {
        if isFinalExamRound(currentRoundIndex) {
            return finalExamSession?.questions ?? []
        }
        return TemperatureCurriculum.cards(forRound: currentRoundIndex, subRoundIndex: currentSubRoundIndex)
    }

    func currentExamCard() -> TemperatureCard? {
        guard let session = finalExamSession,
              session.currentQuestionIndex < session.questions.count else { return nil }
        return session.questions[session.currentQuestionIndex]
    }

    func isSubRoundComplete(_ roundIndex: Int, subRoundIndex: Int) -> Bool {
        if isFinalExamRound(roundIndex) {
            return hasPassedFinalExam
        }
        if subRoundIndex == TemperatureGameConstants.mixedSubRoundIndex {
            let cards = cardsForSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
            guard !cards.isEmpty else { return false }
            return cards.allSatisfy { progress(for: $0).isMixedLearned }
        }
        let cards = TemperatureCurriculum.cards(forRound: roundIndex, subRoundIndex: subRoundIndex)
        guard !cards.isEmpty else { return false }
        return cards.allSatisfy { progress(for: $0).isLearned }
    }

    func isRoundComplete(_ roundIndex: Int) -> Bool {
        if isFinalExamRound(roundIndex) {
            return hasPassedFinalExam
        }
        return (0..<TemperatureGameConstants.subRoundsPerRound).allSatisfy {
            isSubRoundComplete(roundIndex, subRoundIndex: $0)
        }
    }

    func areLearningRoundsComplete() -> Bool {
        (0..<TemperatureGameConstants.learningRoundCount).allSatisfy(isRoundComplete)
    }

    var isActiveFinalExamSession: Bool {
        guard isFinalExamRound(currentRoundIndex),
              let session = finalExamSession,
              !session.isComplete else { return false }
        return true
    }

    func examCorrectCount() -> Int {
        finalExamSession?.correctCount ?? 0
    }

    func examRemainingCount() -> Int {
        guard let session = finalExamSession else { return 0 }
        return max(0, session.totalQuestions - session.currentQuestionIndex)
    }

    func learnedCountInCurrentSubRound() -> Int {
        if isFinalExamRound(currentRoundIndex) {
            return examCorrectCount()
        }
        if currentSubRoundIndex == TemperatureGameConstants.mixedSubRoundIndex {
            return cardsForSubRound(
                roundIndex: currentRoundIndex,
                subRoundIndex: currentSubRoundIndex
            ).filter { progress(for: $0).isMixedLearned }.count
        }
        return currentSubRoundCards().filter { progress(for: $0).isLearned }.count
    }

    func totalCountInCurrentSubRound() -> Int {
        if isFinalExamRound(currentRoundIndex) {
            return finalExamSession?.totalQuestions ?? TemperatureGameConstants.examQuestionCount
        }
        if currentSubRoundIndex == TemperatureGameConstants.mixedSubRoundIndex {
            return cardsForSubRound(
                roundIndex: currentRoundIndex,
                subRoundIndex: currentSubRoundIndex
            ).count
        }
        return currentSubRoundCards().count
    }

    func anchorCount(in roundIndex: Int) -> Int {
        TemperatureCurriculum.rounds.first(where: { $0.index == roundIndex })?.anchorCount ?? 5
    }

    @discardableResult
    func advanceSubRoundIfNeeded() -> Bool {
        guard !isFinalExamRound(currentRoundIndex) else { return false }
        guard isSubRoundComplete(currentRoundIndex, subRoundIndex: currentSubRoundIndex) else { return false }
        guard currentSubRoundIndex < TemperatureGameConstants.subRoundsPerRound - 1 else { return false }
        currentSubRoundIndex += 1
        save()
        return true
    }

    func advanceToNextRoundIfNeeded() {
        guard isRoundComplete(currentRoundIndex) else { return }
        let nextIndex = currentRoundIndex + 1
        if nextIndex < TemperatureCurriculum.rounds.count {
            currentRoundIndex = nextIndex
            currentSubRoundIndex = 0
            save()
        }
    }

    func normalizePosition() {
        if hasPassedFinalExam {
            currentRoundIndex = TemperatureGameConstants.finalExamRoundIndex
            currentSubRoundIndex = 0
            save()
            return
        }

        while !isFinalExamRound(currentRoundIndex),
              isSubRoundComplete(currentRoundIndex, subRoundIndex: currentSubRoundIndex) {
            if currentSubRoundIndex < TemperatureGameConstants.subRoundsPerRound - 1 {
                currentSubRoundIndex += 1
            } else if currentRoundIndex < TemperatureGameConstants.finalExamRoundIndex {
                currentRoundIndex += 1
                currentSubRoundIndex = 0
            } else {
                break
            }
        }

        if areLearningRoundsComplete(),
           currentRoundIndex < TemperatureGameConstants.finalExamRoundIndex {
            currentRoundIndex = TemperatureGameConstants.finalExamRoundIndex
            currentSubRoundIndex = 0
        }

        save()
    }

    func markTipSeen(forRound roundIndex: Int) {
        hasSeenTipForRound.insert(roundIndex)
        save()
    }

    func unmarkTipSeen(forRound roundIndex: Int) {
        hasSeenTipForRound.remove(roundIndex)
        save()
    }

    func shouldShowTipBeforeRound(_ roundIndex: Int) -> Bool {
        !hasSeenTipForRound.contains(roundIndex)
    }

    func subRoundKey(roundIndex: Int, subRoundIndex: Int) -> String {
        "\(roundIndex)-\(subRoundIndex)"
    }

    func shouldShowSubRoundPreview(roundIndex: Int, subRoundIndex: Int) -> Bool {
        guard !isFinalExamRound(roundIndex) else { return false }
        guard subRoundIndex != TemperatureGameConstants.mixedSubRoundIndex else { return false }
        let key = subRoundKey(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        return !previewedSubRoundKeys.contains(key)
    }

    func acknowledgeSubRoundPreview(roundIndex: Int, subRoundIndex: Int) {
        previewedSubRoundKeys.insert(subRoundKey(roundIndex: roundIndex, subRoundIndex: subRoundIndex))
        save()
    }

    func unmarkSubRoundPreview(roundIndex: Int, subRoundIndex: Int) {
        previewedSubRoundKeys.remove(subRoundKey(roundIndex: roundIndex, subRoundIndex: subRoundIndex))
        save()
    }

    func prepareToRedoSubRound(roundIndex: Int, subRoundIndex: Int) {
        guard !isFinalExamRound(roundIndex) else { return }

        currentRoundIndex = roundIndex
        currentSubRoundIndex = subRoundIndex

        let cards = cardsForSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        for card in cards {
            if subRoundIndex == TemperatureGameConstants.mixedSubRoundIndex {
                var progress = progress(for: card)
                progress.mixedConsecutiveCorrect = 0
                progressByCardID[card.id] = progress
            } else {
                progressByCardID.removeValue(forKey: card.id)
            }
        }

        unmarkSubRoundPreview(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        save()
    }

    func prepareToRedoFinalExam() {
        guard areLearningRoundsComplete() else { return }
        currentRoundIndex = TemperatureGameConstants.finalExamRoundIndex
        currentSubRoundIndex = 0
        clearFinalExamSession()
        save()
    }

    var canAccessFinalExam: Bool {
        areLearningRoundsComplete()
    }

    var isModuleComplete: Bool {
        hasPassedFinalExam
    }

    func isFinalExamRound(_ roundIndex: Int) -> Bool {
        roundIndex == TemperatureGameConstants.finalExamRoundIndex
    }

    func resetProgress() {
        progressByCardID = [:]
        currentRoundIndex = 0
        currentSubRoundIndex = 0
        hasSeenTipForRound = []
        previewedSubRoundKeys = []
        hasPassedFinalExam = false
        finalExamSession = nil
        save()
    }

    private struct PersistedState: Codable {
        var progressByCardID: [String: CardProgress]
        var currentRoundIndex: Int
        var currentSubRoundIndex: Int?
        var hasSeenTipForRound: [Int]
        var previewedSubRoundKeys: [String]?
        var previewedRoundIndices: [Int]?
        var hasPassedFinalExam: Bool?
        var finalExamSession: FinalExamSession?
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let state = try? JSONDecoder().decode(PersistedState.self, from: data)
        else { return }

        progressByCardID = state.progressByCardID
        currentRoundIndex = state.currentRoundIndex
        currentSubRoundIndex = state.currentSubRoundIndex ?? 0
        hasSeenTipForRound = Set(state.hasSeenTipForRound)
        if let keys = state.previewedSubRoundKeys {
            previewedSubRoundKeys = Set(keys)
        } else {
            // Ignore legacy previewedRoundIndices — it tracked whole rounds and could
            // incorrectly mark a new sub-round preview as already seen.
            previewedSubRoundKeys = []
        }
        hasPassedFinalExam = state.hasPassedFinalExam ?? false
        finalExamSession = state.finalExamSession
    }

    private func save() {
        let state = PersistedState(
            progressByCardID: progressByCardID,
            currentRoundIndex: currentRoundIndex,
            currentSubRoundIndex: currentSubRoundIndex,
            hasSeenTipForRound: Array(hasSeenTipForRound),
            previewedSubRoundKeys: Array(previewedSubRoundKeys),
            hasPassedFinalExam: hasPassedFinalExam,
            finalExamSession: finalExamSession
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
