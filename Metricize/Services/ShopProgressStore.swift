//
//  ShopProgressStore.swift
//  Metricize
//

import Foundation

@Observable
final class ShopProgressStore {
    private let storageKey = "metricize.shop.progress"
    private(set) var progressByCardID: [String: CardProgress] = [:]
    private(set) var currentRoundIndex: Int = 0
    private(set) var currentSubRoundIndex: Int = 0
    private(set) var hasSeenTipForRound: Set<Int> = []
    private(set) var hasPassedFinalExam: Bool = false
    private(set) var finalExamSession: ShopFinalExamSession?
    private(set) var releasedCardCountByKey: [String: Int] = [:]
    private(set) var previewedReleaseCountByKey: [String: Int] = [:]
    private(set) var pendingBatchReviewKey: String?

    init() {
        load()
        normalizePosition()
    }

    func progress(for card: ShopCard) -> CardProgress {
        progressByCardID[card.id] ?? CardProgress()
    }

    func recordAnswer(for card: ShopCard, correct: Bool) {
        var progress = progress(for: card)
        let inMixedPractice = currentSubRoundIndex == ShopGameConstants.mixedSubRoundIndex
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

    func startFinalExamSession(_ questions: [ShopCard]) {
        finalExamSession = ShopFinalExamSession(questions: questions)
        currentRoundIndex = ShopGameConstants.finalExamRoundIndex
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

    func allCardsForSubRound(roundIndex: Int, subRoundIndex: Int) -> [ShopCard] {
        ShopCurriculum.cards(forRound: roundIndex, subRoundIndex: subRoundIndex)
    }

    func usesGradualRelease(subRoundIndex: Int) -> Bool {
        subRoundIndex != ShopGameConstants.mixedSubRoundIndex
    }

    func subRoundKey(roundIndex: Int, subRoundIndex: Int) -> String {
        "\(roundIndex)-\(subRoundIndex)"
    }

    func ensureReleasedCountInitialized(roundIndex: Int, subRoundIndex: Int) {
        guard usesGradualRelease(subRoundIndex: subRoundIndex) else { return }
        let key = subRoundKey(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        guard releasedCardCountByKey[key] == nil else { return }
        let total = allCardsForSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex).count
        releasedCardCountByKey[key] = min(ShopGameConstants.learningBatchSize, total)
        save()
    }

    func releasedCardCount(roundIndex: Int, subRoundIndex: Int) -> Int {
        guard usesGradualRelease(subRoundIndex: subRoundIndex) else {
            return allCardsForSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex).count
        }
        ensureReleasedCountInitialized(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        let key = subRoundKey(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        let total = allCardsForSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex).count
        return min(releasedCardCountByKey[key] ?? ShopGameConstants.learningBatchSize, total)
    }

    func currentSubRoundCards() -> [ShopCard] {
        if isFinalExamRound(currentRoundIndex) {
            return finalExamSession?.questions ?? []
        }

        let all = allCardsForSubRound(roundIndex: currentRoundIndex, subRoundIndex: currentSubRoundIndex)
        guard usesGradualRelease(subRoundIndex: currentSubRoundIndex) else { return all }
        let released = releasedCardCount(roundIndex: currentRoundIndex, subRoundIndex: currentSubRoundIndex)
        return Array(all.prefix(released))
    }

    func previewedReleaseCount(roundIndex: Int, subRoundIndex: Int) -> Int {
        let key = subRoundKey(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        return previewedReleaseCountByKey[key] ?? 0
    }

    func cardsForBatchReview(roundIndex: Int, subRoundIndex: Int) -> [ShopCard] {
        let all = allCardsForSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        guard usesGradualRelease(subRoundIndex: subRoundIndex) else { return [] }

        let released = releasedCardCount(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        let previewed = previewedReleaseCount(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        guard previewed < released else { return [] }
        return Array(all[previewed..<released])
    }

    func releaseNextBatchIfCurrentSetComplete(roundIndex: Int, subRoundIndex: Int) {
        guard usesGradualRelease(subRoundIndex: subRoundIndex) else { return }
        guard isCurrentReleasedSetComplete(roundIndex: roundIndex, subRoundIndex: subRoundIndex) else { return }
        guard hasMoreCardsToRelease(roundIndex: roundIndex, subRoundIndex: subRoundIndex) else { return }
        guard previewedReleaseCount(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
            >= releasedCardCount(roundIndex: roundIndex, subRoundIndex: subRoundIndex) else { return }

        let key = subRoundKey(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        let all = allCardsForSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        let released = releasedCardCount(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        releasedCardCountByKey[key] = min(released + ShopGameConstants.learningBatchSize, all.count)
        save()
    }

    func hasMoreCardsToRelease(roundIndex: Int, subRoundIndex: Int) -> Bool {
        let all = allCardsForSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        return releasedCardCount(roundIndex: roundIndex, subRoundIndex: subRoundIndex) < all.count
    }

    func isCurrentReleasedSetComplete(roundIndex: Int, subRoundIndex: Int) -> Bool {
        guard usesGradualRelease(subRoundIndex: subRoundIndex) else { return false }
        let active = currentReleasedCards(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        guard !active.isEmpty else { return false }
        return active.allSatisfy { progress(for: $0).isLearned }
    }

    func currentReleasedCards(roundIndex: Int, subRoundIndex: Int) -> [ShopCard] {
        let all = allCardsForSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        let released = releasedCardCount(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        return Array(all.prefix(released))
    }

    func shouldShowBatchReview(roundIndex: Int, subRoundIndex: Int) -> Bool {
        guard usesGradualRelease(subRoundIndex: subRoundIndex) else { return false }
        let key = subRoundKey(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        if pendingBatchReviewKey == key { return true }

        ensureReleasedCountInitialized(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        return previewedReleaseCount(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
            < releasedCardCount(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
    }

    func markPendingBatchReview(roundIndex: Int, subRoundIndex: Int) {
        pendingBatchReviewKey = subRoundKey(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        save()
    }

    func acknowledgeBatchReview(roundIndex: Int, subRoundIndex: Int) {
        let key = subRoundKey(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        let released = releasedCardCount(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        previewedReleaseCountByKey[key] = released
        if pendingBatchReviewKey == key {
            pendingBatchReviewKey = nil
        }
        save()
    }

    func currentExamCard() -> ShopCard? {
        guard let session = finalExamSession,
              session.currentQuestionIndex < session.questions.count else { return nil }
        return session.questions[session.currentQuestionIndex]
    }

    func isSubRoundComplete(_ roundIndex: Int, subRoundIndex: Int) -> Bool {
        if isFinalExamRound(roundIndex) {
            return hasPassedFinalExam
        }
        if subRoundIndex == ShopGameConstants.mixedSubRoundIndex {
            let cards = allCardsForSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
            guard !cards.isEmpty else { return false }
            return cards.allSatisfy { progress(for: $0).isMixedLearned }
        }
        let cards = allCardsForSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        guard !cards.isEmpty else { return false }
        return cards.allSatisfy { progress(for: $0).isLearned }
    }

    func isRoundComplete(_ roundIndex: Int) -> Bool {
        if isFinalExamRound(roundIndex) {
            return hasPassedFinalExam
        }
        return (0..<ShopGameConstants.subRoundsPerRound).allSatisfy {
            isSubRoundComplete(roundIndex, subRoundIndex: $0)
        }
    }

    func areLearningRoundsComplete() -> Bool {
        (0..<ShopGameConstants.learningRoundCount).allSatisfy(isRoundComplete)
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
        if currentSubRoundIndex == ShopGameConstants.mixedSubRoundIndex {
            return allCardsForSubRound(
                roundIndex: currentRoundIndex,
                subRoundIndex: currentSubRoundIndex
            ).filter { progress(for: $0).isMixedLearned }.count
        }
        return allCardsForSubRound(
            roundIndex: currentRoundIndex,
            subRoundIndex: currentSubRoundIndex
        ).filter { progress(for: $0).isLearned }.count
    }

    func totalCountInCurrentSubRound() -> Int {
        if isFinalExamRound(currentRoundIndex) {
            return finalExamSession?.totalQuestions ?? ShopGameConstants.examQuestionCount
        }
        if currentSubRoundIndex == ShopGameConstants.mixedSubRoundIndex {
            return allCardsForSubRound(
                roundIndex: currentRoundIndex,
                subRoundIndex: currentSubRoundIndex
            ).count
        }
        return allCardsForSubRound(
            roundIndex: currentRoundIndex,
            subRoundIndex: currentSubRoundIndex
        ).count
    }

    func anchorCount(in roundIndex: Int) -> Int {
        ShopCurriculum.rounds.first(where: { $0.index == roundIndex })?.anchorCount ?? 5
    }

    @discardableResult
    func advanceSubRoundIfNeeded() -> Bool {
        guard !isFinalExamRound(currentRoundIndex) else { return false }
        guard isSubRoundComplete(currentRoundIndex, subRoundIndex: currentSubRoundIndex) else { return false }
        guard currentSubRoundIndex < ShopGameConstants.subRoundsPerRound - 1 else { return false }
        currentSubRoundIndex += 1
        save()
        return true
    }

    func advanceToNextRoundIfNeeded() {
        guard isRoundComplete(currentRoundIndex) else { return }
        let nextIndex = currentRoundIndex + 1
        if nextIndex < ShopCurriculum.rounds.count {
            currentRoundIndex = nextIndex
            currentSubRoundIndex = 0
            save()
        }
    }

    func normalizePosition() {
        if hasPassedFinalExam {
            currentRoundIndex = ShopGameConstants.finalExamRoundIndex
            currentSubRoundIndex = 0
            save()
            return
        }

        while !isFinalExamRound(currentRoundIndex),
              isSubRoundComplete(currentRoundIndex, subRoundIndex: currentSubRoundIndex) {
            if currentSubRoundIndex < ShopGameConstants.subRoundsPerRound - 1 {
                currentSubRoundIndex += 1
            } else if currentRoundIndex < ShopGameConstants.finalExamRoundIndex {
                currentRoundIndex += 1
                currentSubRoundIndex = 0
            } else {
                break
            }
        }

        if areLearningRoundsComplete(),
           currentRoundIndex < ShopGameConstants.finalExamRoundIndex {
            currentRoundIndex = ShopGameConstants.finalExamRoundIndex
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

    var isModuleComplete: Bool {
        hasPassedFinalExam
    }

    func isFinalExamRound(_ roundIndex: Int) -> Bool {
        roundIndex == ShopGameConstants.finalExamRoundIndex
    }

    func prepareToRedoSubRound(roundIndex: Int, subRoundIndex: Int) {
        guard !isFinalExamRound(roundIndex) else { return }

        currentRoundIndex = roundIndex
        currentSubRoundIndex = subRoundIndex

        let cards = allCardsForSubRound(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
        for card in cards {
            if subRoundIndex == ShopGameConstants.mixedSubRoundIndex {
                var progress = progress(for: card)
                progress.mixedConsecutiveCorrect = 0
                progressByCardID[card.id] = progress
            } else {
                progressByCardID.removeValue(forKey: card.id)
            }
        }

        if usesGradualRelease(subRoundIndex: subRoundIndex) {
            let key = subRoundKey(roundIndex: roundIndex, subRoundIndex: subRoundIndex)
            previewedReleaseCountByKey[key] = 0
            releasedCardCountByKey.removeValue(forKey: key)
            if pendingBatchReviewKey == key {
                pendingBatchReviewKey = nil
            }
        }

        save()
    }

    func prepareToRedoFinalExam() {
        guard areLearningRoundsComplete() else { return }
        currentRoundIndex = ShopGameConstants.finalExamRoundIndex
        currentSubRoundIndex = 0
        clearFinalExamSession()
        save()
    }

    var canAccessFinalExam: Bool {
        areLearningRoundsComplete()
    }

    func resetProgress() {
        progressByCardID = [:]
        currentRoundIndex = 0
        currentSubRoundIndex = 0
        hasSeenTipForRound = []
        hasPassedFinalExam = false
        finalExamSession = nil
        releasedCardCountByKey = [:]
        previewedReleaseCountByKey = [:]
        pendingBatchReviewKey = nil
        save()
    }

    private struct PersistedState: Codable {
        var progressByCardID: [String: CardProgress]
        var currentRoundIndex: Int
        var currentSubRoundIndex: Int?
        var hasSeenTipForRound: [Int]
        var hasPassedFinalExam: Bool?
        var finalExamSession: ShopFinalExamSession?
        var releasedCardCountByKey: [String: Int]?
        var previewedReleaseCountByKey: [String: Int]?
        var pendingBatchReviewKey: String?
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
        hasPassedFinalExam = state.hasPassedFinalExam ?? false
        finalExamSession = state.finalExamSession
        releasedCardCountByKey = state.releasedCardCountByKey ?? [:]
        previewedReleaseCountByKey = state.previewedReleaseCountByKey ?? [:]
        pendingBatchReviewKey = state.pendingBatchReviewKey
    }

    private func save() {
        let state = PersistedState(
            progressByCardID: progressByCardID,
            currentRoundIndex: currentRoundIndex,
            currentSubRoundIndex: currentSubRoundIndex,
            hasSeenTipForRound: Array(hasSeenTipForRound),
            hasPassedFinalExam: hasPassedFinalExam,
            finalExamSession: finalExamSession,
            releasedCardCountByKey: releasedCardCountByKey,
            previewedReleaseCountByKey: previewedReleaseCountByKey,
            pendingBatchReviewKey: pendingBatchReviewKey
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
