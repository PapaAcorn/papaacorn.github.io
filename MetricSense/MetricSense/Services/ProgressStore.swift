import Combine
import Foundation

final class ProgressStore: ObservableObject {
    @Published private(set) var progress: ProgressByQuestion = [:]

    private let defaults: UserDefaults
    private let storageKey: String

    init(
        defaults: UserDefaults = .standard,
        storageKey: String = "metric-sense-temperature-progress-v1"
    ) {
        self.defaults = defaults
        self.storageKey = storageKey
        load()
    }

    func progress(for key: String) -> QuestionProgress {
        progress[key] ?? QuestionProgress()
    }

    func recordAnswer(for key: String, correct: Bool) {
        var entry = progress(for: key)
        entry.recordAnswer(correct: correct, requiredStreak: GameConstants.learnedStreakRequired)
        progress[key] = entry
        save()
    }

    func reset() {
        progress = [:]
        save()
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode(ProgressByQuestion.self, from: data) {
            progress = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
