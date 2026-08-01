//
//  MetricUnitsProgressStore.swift
//  Metricize
//

import Foundation

@Observable
final class MetricUnitsProgressStore {
    private let storageKey = "metricize.metricUnits.progress"
    private(set) var progressByCardID: [String: CardProgress] = [:]
    private(set) var currentSubRoundIndex: Int = 0
    private(set) var hasSeenRoundTip = false
    private(set) var previewedSubRoundKeys: Set<String> = []
    private(set) var hasCompletedPractice = false

    init() {
        load()
        normalizePosition()
    }

    func progress(for card: MetricUnitsCard) -> CardProgress {
        progressByCardID[card.id] ?? CardProgress()
    }

    func recordAnswer(for card: MetricUnitsCard, correct: Bool) {
        var progress = progress(for: card)
        let inMixedPractice = currentSubRoundIndex == MetricUnitsGameConstants.mixedSubRoundIndex

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

    func currentSubRoundCards() -> [MetricUnitsCard] {
        MetricUnitsCurriculum.cards(forSubRoundIndex: currentSubRoundIndex)
    }

    func cardsForSubRound(subRoundIndex: Int) -> [MetricUnitsCard] {
        MetricUnitsCurriculum.cards(forSubRoundIndex: subRoundIndex)
    }

    func isSubRoundComplete(_ subRoundIndex: Int) -> Bool {
        if subRoundIndex == MetricUnitsGameConstants.mixedSubRoundIndex {
            let cards = cardsForSubRound(subRoundIndex: subRoundIndex)
            guard !cards.isEmpty else { return false }
            return cards.allSatisfy { progress(for: $0).isMixedLearned }
        }
        let cards = cardsForSubRound(subRoundIndex: subRoundIndex)
        guard !cards.isEmpty else { return false }
        return cards.allSatisfy { progress(for: $0).isLearned }
    }

    var isRoundComplete: Bool {
        (0..<MetricUnitsGameConstants.subRoundsPerRound).allSatisfy(isSubRoundComplete)
    }

    var isModuleComplete: Bool {
        hasCompletedPractice
    }

    func learnedCountInCurrentSubRound() -> Int {
        if currentSubRoundIndex == MetricUnitsGameConstants.mixedSubRoundIndex {
            return cardsForSubRound(subRoundIndex: currentSubRoundIndex)
                .filter { progress(for: $0).isMixedLearned }
                .count
        }
        return currentSubRoundCards().filter { progress(for: $0).isLearned }.count
    }

    func totalCountInCurrentSubRound() -> Int {
        currentSubRoundCards().count
    }

    @discardableResult
    func advanceSubRoundIfNeeded() -> Bool {
        guard isSubRoundComplete(currentSubRoundIndex) else { return false }
        guard currentSubRoundIndex < MetricUnitsGameConstants.subRoundsPerRound - 1 else { return false }
        currentSubRoundIndex += 1
        save()
        return true
    }

    func normalizePosition() {
        while isSubRoundComplete(currentSubRoundIndex) {
            if currentSubRoundIndex < MetricUnitsGameConstants.subRoundsPerRound - 1 {
                currentSubRoundIndex += 1
            } else {
                hasCompletedPractice = true
                break
            }
        }
        save()
    }

    func markRoundTipSeen() {
        hasSeenRoundTip = true
        save()
    }

    func unmarkRoundTipSeen() {
        hasSeenRoundTip = false
        save()
    }

    func shouldShowRoundTip() -> Bool {
        !hasSeenRoundTip
    }

    func subRoundKey(subRoundIndex: Int) -> String {
        "0-\(subRoundIndex)"
    }

    func shouldShowSubRoundPreview(subRoundIndex: Int) -> Bool {
        guard subRoundIndex != MetricUnitsGameConstants.mixedSubRoundIndex else { return false }
        return !previewedSubRoundKeys.contains(subRoundKey(subRoundIndex: subRoundIndex))
    }

    func acknowledgeSubRoundPreview(subRoundIndex: Int) {
        previewedSubRoundKeys.insert(subRoundKey(subRoundIndex: subRoundIndex))
        save()
    }

    func unmarkSubRoundPreview(subRoundIndex: Int) {
        previewedSubRoundKeys.remove(subRoundKey(subRoundIndex: subRoundIndex))
        save()
    }

    func prepareToRedoSubRound(subRoundIndex: Int) {
        currentSubRoundIndex = subRoundIndex

        let cards = cardsForSubRound(subRoundIndex: subRoundIndex)
        for card in cards {
            if subRoundIndex == MetricUnitsGameConstants.mixedSubRoundIndex {
                var progress = progress(for: card)
                progress.mixedConsecutiveCorrect = 0
                progressByCardID[card.id] = progress
            } else {
                progressByCardID.removeValue(forKey: card.id)
            }
        }

        unmarkSubRoundPreview(subRoundIndex: subRoundIndex)
        save()
    }

    func markPracticeComplete() {
        hasCompletedPractice = true
        save()
    }

    func resetProgress() {
        progressByCardID = [:]
        currentSubRoundIndex = 0
        hasSeenRoundTip = false
        previewedSubRoundKeys = []
        hasCompletedPractice = false
        save()
    }

    private struct PersistedState: Codable {
        var progressByCardID: [String: CardProgress]
        var currentSubRoundIndex: Int
        var hasSeenRoundTip: Bool
        var previewedSubRoundKeys: [String]
        var hasCompletedPractice: Bool
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let state = try? JSONDecoder().decode(PersistedState.self, from: data)
        else { return }

        progressByCardID = state.progressByCardID
        currentSubRoundIndex = state.currentSubRoundIndex
        hasSeenRoundTip = state.hasSeenRoundTip
        previewedSubRoundKeys = Set(state.previewedSubRoundKeys)
        hasCompletedPractice = state.hasCompletedPractice
    }

    private func save() {
        let state = PersistedState(
            progressByCardID: progressByCardID,
            currentSubRoundIndex: currentSubRoundIndex,
            hasSeenRoundTip: hasSeenRoundTip,
            previewedSubRoundKeys: Array(previewedSubRoundKeys),
            hasCompletedPractice: hasCompletedPractice
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
