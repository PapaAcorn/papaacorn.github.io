import SwiftUI

@main
struct MetricSenseApp: App {
    @StateObject private var progressStore: ProgressStore
    @StateObject private var gameViewModel: TemperatureGameViewModel

    init() {
        let store = ProgressStore()
        _progressStore = StateObject(wrappedValue: store)
        _gameViewModel = StateObject(wrappedValue: TemperatureGameViewModel(progressStore: store))
    }

    var body: some Scene {
        WindowGroup {
            TemperatureGameView(viewModel: gameViewModel)
                .environmentObject(progressStore)
        }
    }
}
