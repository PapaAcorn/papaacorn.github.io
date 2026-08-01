//
//  ContentView.swift
//  Metricize
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        AppRootView()
    }
}

#Preview {
    ContentView()
        .environment(AppSettingsStore())
        .environment(\.metricPalette, MetricPalette.dark)
}
