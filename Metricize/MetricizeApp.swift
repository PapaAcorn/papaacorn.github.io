//
//  MetricizeApp.swift
//  Metricize
//
//  Created by James on 5/23/26.
//

import SwiftUI
#if canImport(AppIntents)
import AppIntents
#endif
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@main
struct MetricizeApp: App {
    @State private var settings = AppSettingsStore()

    init() {
        AppFont.register()
        #if canImport(AppIntents)
        MetricizeShortcutRegistration.update()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView(settings: settings)
        }
    }
}

private struct RootView: View {
    let settings: AppSettingsStore
    @Environment(\.colorScheme) private var systemColorScheme

    private var activeColorScheme: ColorScheme {
        settings.appearanceMode.preferredColorScheme ?? systemColorScheme
    }

    var body: some View {
        ContentView()
            .environment(settings)
            .environment(\.metricPalette, MetricPalette.forScheme(activeColorScheme))
            .preferredColorScheme(settings.appearanceMode.preferredColorScheme)
            .onOpenURL { url in
                if url.host == "calculator" || url.path == "/calculator" {
                    AppNavigationStore.shared.openConversionCalculator()
                }
            }
    }
}
