//
//  ModuleUnlockStore.swift
//  Metricize
//

import Foundation

@Observable
final class ModuleUnlockStore {
    private let storageKey = "metricize.module.unlocks"
    private(set) var completedModules: Set<AppModule> = []

    init() {
        load()
    }

    func isComplete(_ module: AppModule) -> Bool {
        completedModules.contains(module)
    }

    func isUnlocked(_ module: AppModule) -> Bool {
        if module == .conversionCalculator { return true }
        if module == .insideAndOut {
            return isComplete(.howToUse)
                || isComplete(.insideOutsideBasics)
                || isComplete(.learnInsideOutside)
        }
        if module == .inTheKitchen {
            return isComplete(.howToUse) || isComplete(.kitchenBasics)
        }
        if module == .inTheShop {
            return isComplete(.howToUse) || isComplete(.shopBasics)
        }
        if module == .onTheRoad {
            return isComplete(.howToUse) || isComplete(.roadBasics)
        }
        if module == .hereToThere {
            return isComplete(.howToUse) || isComplete(.hereToThereBasics)
        }
        if module == .atTheGym {
            return isComplete(.howToUse) || isComplete(.gymBasics)
        }
        guard let prerequisite = module.prerequisite() else { return true }
        return completedModules.contains(prerequisite)
    }

    func markComplete(_ module: AppModule) {
        completedModules.insert(module)
        save()
    }

    func clearCompletion(_ module: AppModule) {
        completedModules.remove(module)
        save()
    }

    func clearInsideAndOutIntro() {
        clearCompletion(AppModule.insideAndOutIntroCompletion)
    }

    func clearKitchenIntro() {
        clearCompletion(AppModule.kitchenIntroCompletion)
    }

    func clearShopIntro() {
        clearCompletion(AppModule.shopIntroCompletion)
    }

    func clearRoadIntro() {
        clearCompletion(AppModule.roadIntroCompletion)
    }

    func clearHereToThereIntro() {
        clearCompletion(AppModule.hereToThereIntroCompletion)
    }

    func clearGymIntro() {
        clearCompletion(AppModule.gymIntroCompletion)
    }

    func clearMetricUnitsIntro() {
        clearCompletion(.metricUnitsIntro)
    }

    /// Clears all module completion flags and learning progress. User must re-read intro pages.
    func resetAllProgress(
        temperatureStore: TemperatureProgressStore,
        kitchenStore: KitchenProgressStore? = nil,
        shopStore: ShopProgressStore? = nil,
        metricUnitsStore: MetricUnitsProgressStore? = nil,
        roadStore: RoadProgressStore? = nil,
        hereToThereStore: HereToThereProgressStore? = nil,
        gymStore: GymProgressStore? = nil
    ) {
        completedModules = []
        temperatureStore.resetProgress()
        kitchenStore?.resetProgress()
        shopStore?.resetProgress()
        metricUnitsStore?.resetProgress()
        roadStore?.resetProgress()
        hereToThereStore?.resetProgress()
        gymStore?.resetProgress()
        save()
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let modules = try? JSONDecoder().decode([AppModule].self, from: data)
        else { return }
        completedModules = Set(modules)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(Array(completedModules)) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
