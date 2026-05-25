//
//  MetricizeApp.swift
//  Metricize
//
//  Created by James on 5/23/26.
//

import SwiftUI

@main
struct MetricizeApp: App {
    @State private var settings = AppSettingsStore()

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
