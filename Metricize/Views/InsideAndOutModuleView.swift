//
//  InsideAndOutModuleView.swift
//  Metricize
//

import SwiftUI

struct InsideAndOutModuleView: View {
    let unlockStore: ModuleUnlockStore
    let progressStore: TemperatureProgressStore

    @State private var showLearning = false

    private var hasCompletedIntro: Bool {
        AppModule.hasCompletedInsideAndOutIntro(in: unlockStore)
    }

    var body: some View {
        Group {
            if showLearning || hasCompletedIntro {
                TemperatureGameView(progressStore: progressStore)
            } else {
                OnboardingModuleView(
                    module: .insideAndOut,
                    pages: InsideOutsideBasicsContent.pages,
                    unlockStore: unlockStore,
                    finalButtonTitle: "Start Learning",
                    completionModule: AppModule.insideAndOutIntroCompletion,
                    onComplete: { showLearning = true }
                )
            }
        }
    }
}
