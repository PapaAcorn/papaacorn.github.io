//
//  MetricizeApp.swift
//  Metricize
//
//  Created by James on 5/23/26.
//

import SwiftUI
import UIKit

@main
struct MetricizeApp: App {
    @UIApplicationDelegateAdaptor(MetricizeAppDelegate.self) private var appDelegate

    @State private var settings = AppSettingsStore()

    init() {
        AppFont.register()
        MetricizeShortcutRegistration.ensureLinked()
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
    }
}
