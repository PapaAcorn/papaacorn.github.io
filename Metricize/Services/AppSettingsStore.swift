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
        didSet { save() }
    }

    var requiredConsecutiveCorrect: Int {
        didSet {
            let clamped = min(max(requiredConsecutiveCorrect, 1), 5)
            if clamped != requiredConsecutiveCorrect {
                requiredConsecutiveCorrect = clamped
                return
            }
            LearningPreferences.saveRequiredConsecutiveCorrect(clamped)
        }
    }

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
    }

    private func save() {
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: appearanceKey)
    }
}
