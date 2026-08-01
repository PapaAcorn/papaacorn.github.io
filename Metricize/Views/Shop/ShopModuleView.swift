//
//  ShopModuleView.swift
//  Metricize
//

import SwiftUI

struct ShopModuleView: View {
    let unlockStore: ModuleUnlockStore
    let progressStore: ShopProgressStore
    let temperatureProgress: TemperatureProgressStore
    let kitchenProgress: KitchenProgressStore
    let metricUnitsProgress: MetricUnitsProgressStore
    let roadProgress: RoadProgressStore
    let hereToThereProgress: HereToThereProgressStore
    let gymProgress: GymProgressStore

    @Environment(AppSettingsStore.self) private var settings
    @State private var route: ShopModuleRoute?
    @State private var learningSessionID = UUID()

    private var activeRoute: ShopModuleRoute {
        route ?? (AppModule.hasCompletedShopIntro(in: unlockStore) ? .learning : .intro)
    }

    var body: some View {
        Group {
            switch activeRoute {
            case .intro:
                OnboardingModuleView(
                    module: .inTheShop,
                    pages: ShopBasicsContent.pages,
                    unlockStore: unlockStore,
                    finalButtonTitle: "Start Learning",
                    completionModule: AppModule.shopBasics,
                    onComplete: { route = .learning }
                )
            case .learning:
                ShopGameView(
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
                            shopProgress: progressStore,
                            hereToThereProgress: hereToThereProgress,
                            gymProgress: gymProgress
                        )
                    }
                }
            case .introReview:
                OnboardingModuleView(
                    module: .inTheShop,
                    pages: ShopBasicsContent.pages,
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
        unlockStore.clearShopIntro()
        learningSessionID = UUID()
        route = .intro
    }
}

private enum ShopModuleRoute {
    case intro
    case learning
    case introReview
}
