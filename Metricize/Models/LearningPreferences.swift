//
//  LearningPreferences.swift
//  Metricize
//

import Foundation

enum LearningPreferences {
    private static let requiredCorrectKey = "metricize.settings.insideAndOut.learningRequirement"
    private static let accuracyKey = "metricize.settings.insideAndOut.accuracyRequirement"

    static let defaultRequiredConsecutiveCorrect = 3
    static let defaultAccuracyToleranceDegrees = 3

    private static let legacyRequiredCorrectKey = "metricize.settings.requiredCorrect"

    static var requiredConsecutiveCorrect: Int {
        migrateLegacyRequiredCorrectIfNeeded()

        let stored = UserDefaults.standard.integer(forKey: requiredCorrectKey)
        if UserDefaults.standard.object(forKey: requiredCorrectKey) == nil {
            return defaultRequiredConsecutiveCorrect
        }
        if (1...5).contains(stored) { return stored }
        return defaultRequiredConsecutiveCorrect
    }

    static var accuracyToleranceDegrees: Int {
        if UserDefaults.standard.object(forKey: accuracyKey) == nil {
            return defaultAccuracyToleranceDegrees
        }
        let stored = UserDefaults.standard.integer(forKey: accuracyKey)
        if (0...5).contains(stored) { return stored }
        return defaultAccuracyToleranceDegrees
    }

    static func saveRequiredConsecutiveCorrect(_ value: Int) {
        UserDefaults.standard.set(min(max(value, 1), 5), forKey: requiredCorrectKey)
    }

    static func saveAccuracyToleranceDegrees(_ value: Int) {
        UserDefaults.standard.set(min(max(value, 0), 5), forKey: accuracyKey)
    }

    private static func migrateLegacyRequiredCorrectIfNeeded() {
        guard UserDefaults.standard.object(forKey: requiredCorrectKey) == nil else { return }
        guard UserDefaults.standard.object(forKey: legacyRequiredCorrectKey) != nil else { return }

        let legacy = UserDefaults.standard.integer(forKey: legacyRequiredCorrectKey)
        if (1...5).contains(legacy) {
            saveRequiredConsecutiveCorrect(legacy)
        }
        UserDefaults.standard.removeObject(forKey: legacyRequiredCorrectKey)
    }
}
