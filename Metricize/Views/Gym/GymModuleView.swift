//
//  GymModuleView.swift
//  Metricize
//

import SwiftUI

struct GymModuleView: View {
    let unlockStore: ModuleUnlockStore
    let progressStore: GymProgressStore
    let temperatureProgress: TemperatureProgressStore
    let kitchenProgress: KitchenProgressStore
    let metricUnitsProgress: MetricUnitsProgressStore
    let roadProgress: RoadProgressStore
    let shopProgress: ShopProgressStore
    let hereToThereProgress: HereToThereProgressStore

    @Environment(AppSettingsStore.self) private var settings
    @State private var route: GymModuleRoute?
    @State private var learningSessionID = UUID()

    private var activeRoute: GymModuleRoute {
        route ?? (AppModule.hasCompletedGymIntro(in: unlockStore) ? .learning : .intro)
    }

    var body: some View {
        Group {
            switch activeRoute {
            case .intro:
                OnboardingModuleView(
                    module: .atTheGym,
                    pages: GymBasicsContent.pages,
                    unlockStore: unlockStore,
                    finalButtonTitle: "Start Learning",
                    completionModule: AppModule.gymBasics,
                    onComplete: { route = .learning }
                )
            case .learning:
                GymGameView(
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
                            hereToThereProgress: hereToThereProgress,
                            gymProgress: progressStore
                        )
                    }
                }
            case .introReview:
                OnboardingModuleView(
                    module: .atTheGym,
                    pages: GymBasicsContent.pages,
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
        unlockStore.clearGymIntro()
        learningSessionID = UUID()
        route = .intro
    }
}

private enum GymModuleRoute {
    case intro
    case learning
    case introReview
}
