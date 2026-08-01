//
//  HereToThereModuleView.swift
//  Metricize
//

import SwiftUI

struct HereToThereModuleView: View {
    let unlockStore: ModuleUnlockStore
    let progressStore: HereToThereProgressStore
    let temperatureProgress: TemperatureProgressStore
    let kitchenProgress: KitchenProgressStore
    let metricUnitsProgress: MetricUnitsProgressStore
    let roadProgress: RoadProgressStore
    let shopProgress: ShopProgressStore
    let gymProgress: GymProgressStore

    @Environment(AppSettingsStore.self) private var settings
    @State private var route: HereToThereModuleRoute?
    @State private var learningSessionID = UUID()

    private var activeRoute: HereToThereModuleRoute {
        route ?? (AppModule.hasCompletedHereToThereIntro(in: unlockStore) ? .learning : .intro)
    }

    var body: some View {
        Group {
            switch activeRoute {
            case .intro:
                OnboardingModuleView(
                    module: .hereToThere,
                    pages: HereToThereBasicsContent.pages,
                    unlockStore: unlockStore,
                    finalButtonTitle: "Start Learning",
                    completionModule: AppModule.hereToThereBasics,
                    onComplete: { route = .learning }
                )
            case .learning:
                HereToThereGameView(
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
                            roadProgress: roadProgress,
                            shopProgress: shopProgress,
                            hereToThereProgress: progressStore,
                            gymProgress: gymProgress
                        )
                    }
                }
            case .introReview:
                OnboardingModuleView(
                    module: .hereToThere,
                    pages: HereToThereBasicsContent.pages,
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
        unlockStore.clearHereToThereIntro()
        learningSessionID = UUID()
        route = .intro
    }
}

private enum HereToThereModuleRoute {
    case intro
    case learning
    case introReview
}
