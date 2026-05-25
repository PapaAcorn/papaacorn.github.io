//
//  ContentView.swift
//  Metricize
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .environment(AppSettingsStore())
        .modifier(MetricPaletteProvider())
}
