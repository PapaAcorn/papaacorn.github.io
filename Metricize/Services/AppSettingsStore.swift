//
//  AppSettingsStore.swift
//  Metricize
//

import SwiftUI

@Observable
@MainActor
final class AppSettingsStore {
    private let appearanceKey = "metricize.settings.appearance"

    var appearanceMode: AppAppearanceMode {
        didSet { saveAppearance() }
    }

    private(set) var requiredConsecutiveCorrect: Int
    private(set) var accuracyToleranceDegrees: Int

    var preferredColorScheme: ColorScheme? {
        appearanceMode.preferredColorScheme
    }

    init() {
        appearanceMode = .system
        if let raw = UserDefaults.standard.string(forKey: appearanceKey),
           let mode = AppAppearanceMode(rawValue: raw) {
            appearanceMode = mode
        }

        requiredConsecutiveCorrect = LearningPreferences.requiredConsecutiveCorrect
        accuracyToleranceDegrees = LearningPreferences.accuracyToleranceDegrees
    }

    func setRequiredConsecutiveCorrect(_ value: Int) {
        let clamped = min(max(value, 1), 5)
        guard clamped != requiredConsecutiveCorrect else { return }
        requiredConsecutiveCorrect = clamped
        LearningPreferences.saveRequiredConsecutiveCorrect(clamped)
    }

    func setAccuracyToleranceDegrees(_ value: Int) {
        let clamped = min(max(value, 0), 5)
        guard clamped != accuracyToleranceDegrees else { return }
        accuracyToleranceDegrees = clamped
        LearningPreferences.saveAccuracyToleranceDegrees(clamped)
    }

    private func saveAppearance() {
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: appearanceKey)
    }
}
