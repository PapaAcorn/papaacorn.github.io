//
//  OpenConversionCalculatorIntent.swift
//  Metricize
//

import AppIntents
import Foundation

struct OpenConversionCalculatorIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Conversion Calculator"
    static var description = IntentDescription("Opens the Metricize conversion calculator directly.")
    static var openAppWhenRun: Bool = true
    static var isDiscoverable: Bool = true

    static var authenticationPolicy: IntentAuthenticationPolicy {
        .alwaysAllowed
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        AppNavigationStore.shared.openConversionCalculator()
        return .result()
    }
}

struct MetricizeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenConversionCalculatorIntent(),
            phrases: [
                "Open conversion calculator in \(.applicationName)",
                "Convert units in \(.applicationName)",
                "Open \(.applicationName) calculator",
            ],
            shortTitle: "Conversion Calculator",
            systemImageName: "function"
        )
    }
}

enum MetricizeShortcutRegistration {
    static func update() {
        MetricizeShortcuts.updateAppShortcutParameters()
    }
}
