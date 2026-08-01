//
//  ConversionLaunchBridge.swift
//  Metricize
//

import Foundation

enum ConversionScreen: String, CaseIterable, Sendable {
    case converter
    case calculator
}

enum ConversionLaunchBridge {
    private static let pendingScreenKey = "metricize.launch.conversionScreen"

    static func setPending(_ screen: ConversionScreen) {
        UserDefaults.standard.set(screen.rawValue, forKey: pendingScreenKey)
    }

    static func consumePending() -> ConversionScreen? {
        guard let raw = UserDefaults.standard.string(forKey: pendingScreenKey),
              let screen = ConversionScreen(rawValue: raw) else {
            return nil
        }
        UserDefaults.standard.removeObject(forKey: pendingScreenKey)
        return screen
    }
}
