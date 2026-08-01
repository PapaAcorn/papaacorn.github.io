//
//  InsideAndOutModuleView.swift
//  Metricize
//

import SwiftUI

struct InsideAndOutModuleView: View {
    let unlockStore: ModuleUnlockStore
    let progressStore: TemperatureProgressStore
    let kitchenProgress: KitchenProgressStore
    let metricUnitsProgress: MetricUnitsProgressStore
    let roadProgress: RoadProgressStore
    let shopProgress: ShopProgressStore
    let hereToThereProgress: HereToThereProgressStore
    let gymProgress: GymProgressStore

    @Environment(AppSettingsStore.self) private var settings
    @State private var route: InsideAndOutRoute?
    @State private var learningSessionID = UUID()

    private var activeRoute: InsideAndOutRoute {
        route ?? (AppModule.hasCompletedInsideAndOutIntro(in: unlockStore) ? .learning : .intro)
    }

    var body: some View {
        Group {
            switch activeRoute {
            case .intro:
                OnboardingModuleView(
                    module: .insideAndOut,
                    pages: InsideOutsideBasicsContent.pages,
                    unlockStore: unlockStore,
                    finalButtonTitle: "Start Learning",
                    completionModule: AppModule.insideAndOutIntroCompletion,
                    onComplete: { route = .learning }
                )
            case .learning:
                TemperatureGameView(
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
                            temperatureProgress: progressStore,
                            kitchenProgress: kitchenProgress,
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
                    module: .insideAndOut,
                    pages: InsideOutsideBasicsContent.pages,
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
        unlockStore.clearInsideAndOutIntro()
        learningSessionID = UUID()
        route = .intro
    }
}

private enum InsideAndOutRoute {
    case intro
    case learning
    case introReview
}
