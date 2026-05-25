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

    var preferredColorScheme: ColorScheme? {
        appearanceMode.preferredColorScheme
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: appearanceKey),
           let mode = AppAppearanceMode(rawValue: raw) {
            appearanceMode = mode
        } else {
            appearanceMode = .system
        }
    }

    private func save() {
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: appearanceKey)
    }
}
