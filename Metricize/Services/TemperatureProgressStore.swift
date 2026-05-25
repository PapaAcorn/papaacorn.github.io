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
    private(set) var hasSeenTipForRound: Set<Int> = []

    init() {
        load()
    }

    func progress(for card: TemperatureCard) -> CardProgress {
        progressByCardID[card.id] ?? CardProgress()
    }

    func recordAnswer(for card: TemperatureCard, correct: Bool) {
        var progress = progress(for: card)
        if correct {
            progress.consecutiveCorrect += 1
            progress.totalCorrect += 1
        } else {
            progress.consecutiveCorrect = 0
            progress.totalIncorrect += 1
        }
        progressByCardID[card.id] = progress
        save()
    }

    func isRoundComplete(_ roundIndex: Int) -> Bool {
        let cards = TemperatureCurriculum.cards(forRound: roundIndex)
        guard !cards.isEmpty else { return false }
        return cards.allSatisfy { progress(for: $0).isLearned }
    }

    func learnedCardCount(in roundIndex: Int) -> Int {
        TemperatureCurriculum.cards(forRound: roundIndex)
            .filter { progress(for: $0).isLearned }
            .count
    }

    func advanceToNextRoundIfNeeded() {
        guard isRoundComplete(currentRoundIndex) else { return }
        let nextIndex = currentRoundIndex + 1
        if nextIndex < TemperatureCurriculum.rounds.count {
            currentRoundIndex = nextIndex
            save()
        }
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
        TemperatureCurriculum.rounds.indices.allSatisfy(isRoundComplete)
    }

    func resetProgress() {
        progressByCardID = [:]
        currentRoundIndex = 0
        hasSeenTipForRound = []
        save()
    }

    private struct PersistedState: Codable {
        var progressByCardID: [String: CardProgress]
        var currentRoundIndex: Int
        var hasSeenTipForRound: [Int]
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let state = try? JSONDecoder().decode(PersistedState.self, from: data)
        else { return }

        progressByCardID = state.progressByCardID
        currentRoundIndex = state.currentRoundIndex
        hasSeenTipForRound = Set(state.hasSeenTipForRound)
    }

    private func save() {
        let state = PersistedState(
            progressByCardID: progressByCardID,
            currentRoundIndex: currentRoundIndex,
            hasSeenTipForRound: Array(hasSeenTipForRound)
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
