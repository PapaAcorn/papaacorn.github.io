//
//  RoadModuleView.swift
//  Metricize
//

import SwiftUI

struct RoadModuleView: View {
    let unlockStore: ModuleUnlockStore
    let progressStore: RoadProgressStore
    let temperatureProgress: TemperatureProgressStore
    let kitchenProgress: KitchenProgressStore
    let metricUnitsProgress: MetricUnitsProgressStore
    let shopProgress: ShopProgressStore
    let hereToThereProgress: HereToThereProgressStore
    let gymProgress: GymProgressStore

    @Environment(AppSettingsStore.self) private var settings
    @State private var route: RoadModuleRoute?
    @State private var learningSessionID = UUID()

    private var activeRoute: RoadModuleRoute {
        route ?? (AppModule.hasCompletedRoadIntro(in: unlockStore) ? .learning : .intro)
    }

    var body: some View {
        Group {
            switch activeRoute {
            case .intro:
                OnboardingModuleView(
                    module: .onTheRoad,
                    pages: RoadBasicsContent.pages,
                    unlockStore: unlockStore,
                    finalButtonTitle: "Start Learning",
                    completionModule: AppModule.roadBasics,
                    onComplete: { route = .learning }
                )
            case .learning:
                RoadGameView(
                    progressStore: progressStore,
                    settings: settings,
                    onResetModule: resetLearningProgress,
                    onReviewBasics: { route = .introReview }
                )
                .id(learningSessionID)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        SettingsToolbarLink(
                            unlockStore: unlockStore,
                            temperatureProgress: temperatureProgress,
                            kitchenProgress: kitchenProgress,
                            metricUnitsProgress: metricUnitsProgress,
                            roadProgress: progressStore,
                            shopProgress: shopProgress,
                            hereToThereProgress: hereToThereProgress,
                            gymProgress: gymProgress
                        )
                    }
                }
            case .introReview:
                OnboardingModuleView(
                    module: .onTheRoad,
                    pages: RoadBasicsContent.pages,
                    unlockStore: unlockStore,
                    finalButtonTitle: "Done",
                    marksCompletionOnFinish: false,
                    onComplete: { route = .learning }
                )
            }
        }
    }

    private func resetLearningProgress() {
        progressStore.resetProgress()
        unlockStore.clearRoadIntro()
        learningSessionID = UUID()
        route = .intro
    }
}

private enum RoadModuleRoute {
    case intro
    case learning
    case introReview
}
