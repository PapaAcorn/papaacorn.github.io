import Foundation

struct QuestionProgress: Codable, Equatable {
    var attempts: Int = 0
    var correct: Int = 0
    var wrong: Int = 0
    var streak: Int = 0
    var learned: Bool = false
    var lastSeen: TimeInterval = 0

    mutating func recordAnswer(correct: Bool, requiredStreak: Int) {
        attempts += 1
        if correct {
            self.correct += 1
            streak += 1
            if streak >= requiredStreak {
                learned = true
            }
        } else {
            wrong += 1
            streak = 0
        }
        lastSeen = Date().timeIntervalSince1970
    }
}

typealias ProgressByQuestion = [String: QuestionProgress]

enum GameConstants {
    static let learnedStreakRequired = 3
    static let fahrenheitTolerance = 2
    static let celsiusTolerance = 2
}
