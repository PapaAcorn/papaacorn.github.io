//
//  MetricizeAppIntents.swift
//  Metricize
//
//  App Shortcuts must live in the main app target (not a framework/SPM package).
//  See: https://developer.apple.com/documentation/appintents/appshortcutsprovider
//

import AppIntents
import Foundation

/// Registers this target with the App Intents runtime (required for discovery/indexing).
struct MetricizeAppIntentsPackage: AppIntentsPackage {}

struct OpenConverterIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Converter"
    static let description = IntentDescription("Opens MetricizeMe to the unit converter.")
    static let openAppWhenRun = true
    static let isDiscoverable = true
    static let supportedModes: IntentModes = .foreground

    static var authenticationPolicy: IntentAuthenticationPolicy {
        .alwaysAllowed
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        ConversionLaunchBridge.setPending(.converter)
        return .result()
    }
}

struct OpenCalculatorIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Calculator"
    static let description = IntentDescription("Opens MetricizeMe to the unit calculator.")
    static let openAppWhenRun = true
    static let isDiscoverable = true
    static let supportedModes: IntentModes = .foreground

    static var authenticationPolicy: IntentAuthenticationPolicy {
        .alwaysAllowed
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        ConversionLaunchBridge.setPending(.calculator)
        return .result()
    }
}

struct MetricizeMeAppShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor {
        .navy
    }

    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenConverterIntent(),
            phrases: [
                "Open converter in \(.applicationName)",
                "Convert units in \(.applicationName)",
            ],
            shortTitle: "Converter",
            systemImageName: "arrow.left.arrow.right"
        )
        AppShortcut(
            intent: OpenCalculatorIntent(),
            phrases: [
                "Open calculator in \(.applicationName)",
                "Calculate units in \(.applicationName)",
            ],
            shortTitle: "Calculator",
            systemImageName: "function"
        )
    }
}

enum MetricizeShortcutRegistration {
    /// Keeps `MetricizeMeAppShortcuts` linked into the executable for App Intents runtime discovery.
    static let providerType: any AppShortcutsProvider.Type = MetricizeMeAppShortcuts.self

    /// Static shortcuts are indexed automatically via `AppShortcutsProvider`.
    /// Do not call `updateAppShortcutParameters()` here — it talks to `linkd`, which is
    /// often unavailable in Simulator and logs spurious errors when invoked repeatedly.
    static func ensureLinked() {
        _ = providerType
    }
}
