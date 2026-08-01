//
//  MetricUnitsModuleView.swift
//  Metricize
//

import SwiftUI

struct MetricUnitsModuleView: View {
    let unlockStore: ModuleUnlockStore
    let progressStore: MetricUnitsProgressStore
    let temperatureProgress: TemperatureProgressStore
    let kitchenProgress: KitchenProgressStore
    let roadProgress: RoadProgressStore
    let shopProgress: ShopProgressStore
    let hereToThereProgress: HereToThereProgressStore
    let gymProgress: GymProgressStore

    @State private var route: MetricUnitsModuleRoute?
    @State private var learningSessionID = UUID()

    private var activeRoute: MetricUnitsModuleRoute {
        if let route { return route }
        if progressStore.isModuleComplete || !progressStore.progressByCardID.isEmpty {
            return .learning
        }
        if unlockStore.isComplete(.metricUnitsIntro) {
            return .learning
        }
        return .intro
    }

    var body: some View {
        Group {
            switch activeRoute {
            case .intro:
                MetricUnitsIntroView(
                    onStartPractice: beginLearning,
                    onSkipToPractice: beginLearning
                )
            case .learning:
                MetricUnitsGameView(
                    progressStore: progressStore,
                    onResetModule: resetLearningProgress,
                    onReviewIntro: { route = .introReview }
                )
                .id(learningSessionID)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        SettingsToolbarLink(
                            unlockStore: unlockStore,
                            temperatureProgress: temperatureProgress,
                            kitchenProgress: kitchenProgress,
                            metricUnitsProgress: progressStore,
                            roadProgress: roadProgress,
                            shopProgress: shopProgress,
                            hereToThereProgress: hereToThereProgress,
                            gymProgress: gymProgress
                        )
                    }
                }
            case .introReview:
                MetricUnitsIntroView(
                    onStartPractice: { route = .learning },
                    onSkipToPractice: { route = .learning }
                )
            }
        }
    }

    private func beginLearning() {
        unlockStore.markComplete(.metricUnitsIntro)
        route = .learning
    }

    private func resetLearningProgress() {
        progressStore.resetProgress()
        unlockStore.clearMetricUnitsIntro()
        learningSessionID = UUID()
        route = .intro
    }
}

private enum MetricUnitsModuleRoute {
    case intro
    case learning
    case introReview
}
