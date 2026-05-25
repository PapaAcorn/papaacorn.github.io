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
            ContentView()
                .environment(settings)
                .modifier(MetricPaletteProvider())
                .preferredColorScheme(settings.preferredColorScheme)
        }
    }
}
