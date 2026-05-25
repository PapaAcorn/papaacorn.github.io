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
        if module == .insideAndOut {
            return isComplete(.howToUse)
                || isComplete(.insideOutsideBasics)
                || isComplete(.learnInsideOutside)
        }
        guard let prerequisite = module.prerequisite() else { return true }
        return completedModules.contains(prerequisite)
    }

    func markComplete(_ module: AppModule) {
        completedModules.insert(module)
        save()
    }

    func resetAll() {
        completedModules = []
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
