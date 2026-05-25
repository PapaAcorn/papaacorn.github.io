//
//  InsideAndOutModuleView.swift
//  Metricize
//

import SwiftUI

struct InsideAndOutModuleView: View {
    let unlockStore: ModuleUnlockStore
    let progressStore: TemperatureProgressStore

    @State private var route: InsideAndOutRoute?

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
                    onResetModule: resetLearningProgress,
                    onReviewBasics: { route = .introReview }
                )
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
        route = .intro
    }
}

private enum InsideAndOutRoute {
    case intro
    case learning
    case introReview
}
