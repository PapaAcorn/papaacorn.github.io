//
//  LearningPreferences.swift
//  Metricize
//

import Foundation

enum LearningPreferences {
    private static let requiredCorrectKey = "metricize.settings.requiredCorrect"

    static var requiredConsecutiveCorrect: Int {
        let stored = UserDefaults.standard.integer(forKey: requiredCorrectKey)
        if (1...5).contains(stored) { return stored }
        return 3
    }

    static func saveRequiredConsecutiveCorrect(_ value: Int) {
        UserDefaults.standard.set(min(max(value, 1), 5), forKey: requiredCorrectKey)
    }
}
