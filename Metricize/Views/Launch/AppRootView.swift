//
//  AppRootView.swift
//  Metricize
//

import SwiftUI

struct AppRootView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var destination: AppLaunchDestination?
    @State private var conversionScreen: ConversionScreen = .converter
    @State private var temperatureProgress = TemperatureProgressStore()
    @State private var kitchenProgress = KitchenProgressStore()
    @State private var metricUnitsProgress = MetricUnitsProgressStore()
    @State private var roadProgress = RoadProgressStore()
    @State private var shopProgress = ShopProgressStore()
    @State private var hereToThereProgress = HereToThereProgressStore()
    @State private var gymProgress = GymProgressStore()
    @State private var unlockStore = ModuleUnlockStore()

    var body: some View {
        Group {
            if let destination {
                switch destination {
                case .learning:
                    LearningHomeView(
                        unlockStore: unlockStore,
                        temperatureProgress: temperatureProgress,
                        kitchenProgress: kitchenProgress,
                        metricUnitsProgress: metricUnitsProgress,
                        roadProgress: roadProgress,
                        shopProgress: shopProgress,
                        hereToThereProgress: hereToThereProgress,
                        gymProgress: gymProgress
                    ) {
                        self.destination = nil
                    }
                case .conversion:
                    ConversionFlowView(
                        activeScreen: $conversionScreen,
                        onChangeMode: {
                            self.destination = nil
                        }
                    )
                }
            } else {
                LaunchGateView(
                    unlockStore: unlockStore,
                    temperatureProgress: temperatureProgress,
                    kitchenProgress: kitchenProgress,
                    metricUnitsProgress: metricUnitsProgress,
                    roadProgress: roadProgress,
                    shopProgress: shopProgress,
                    hereToThereProgress: hereToThereProgress,
                    gymProgress: gymProgress
                ) { chosen in
                    applyLaunchDestination(chosen)
                }
            }
        }
        .onAppear {
            applyPendingConversionLaunchIfNeeded()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                applyPendingConversionLaunchIfNeeded()
            }
        }
    }

    private func applyLaunchDestination(_ chosen: AppLaunchDestination) {
        switch chosen {
        case .conversion:
            conversionScreen = .converter
            destination = .conversion
        case .learning:
            destination = .learning
        }
    }

    private func applyPendingConversionLaunchIfNeeded() {
        guard let screen = ConversionLaunchBridge.consumePending() else { return }
        conversionScreen = screen
        destination = .conversion
    }
}

#Preview {
    AppRootView()
        .environment(AppSettingsStore())
        .environment(\.metricPalette, MetricPalette.dark)
}
