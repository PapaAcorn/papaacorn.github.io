//
//  KitchenModuleView.swift
//  Metricize
//

import SwiftUI

struct KitchenModuleView: View {
    let unlockStore: ModuleUnlockStore
    let progressStore: KitchenProgressStore
    let temperatureProgress: TemperatureProgressStore
    let metricUnitsProgress: MetricUnitsProgressStore
    let roadProgress: RoadProgressStore
    let shopProgress: ShopProgressStore
    let hereToThereProgress: HereToThereProgressStore
    let gymProgress: GymProgressStore

    @Environment(AppSettingsStore.self) private var settings
    @State private var route: KitchenModuleRoute?
    @State private var learningSessionID = UUID()

    private var activeRoute: KitchenModuleRoute {
        route ?? (AppModule.hasCompletedKitchenIntro(in: unlockStore) ? .learning : .intro)
    }

    var body: some View {
        Group {
            switch activeRoute {
            case .intro:
                OnboardingModuleView(
                    module: .inTheKitchen,
                    pages: KitchenBasicsContent.pages,
                    unlockStore: unlockStore,
                    finalButtonTitle: "Start Learning",
                    completionModule: AppModule.kitchenBasics,
                    onComplete: { route = .learning }
                )
            case .learning:
                KitchenGameView(
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
                            kitchenProgress: progressStore,
                            metricUnitsProgress: metricUnitsProgress,
                            roadProgress: roadProgress,
                            shopProgress: shopProgress,
                            hereToThereProgress: hereToThereProgress,
                            gymProgress: gymProgress
                        )
                    }
                }
            case .introReview:
                OnboardingModuleView(
                    module: .inTheKitchen,
                    pages: KitchenBasicsContent.pages,
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
        unlockStore.clearKitchenIntro()
        learningSessionID = UUID()
        route = .intro
    }
}

private enum KitchenModuleRoute {
    case intro
    case learning
    case introReview
}
