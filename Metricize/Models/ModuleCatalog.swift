//
//  ModuleCatalog.swift
//  Metricize
//
//  Central registry for learnable / purchasable modules. IAP wiring can plug into
//  `ModuleAccessPolicy.inAppPurchase` without touching feature UI code.
//

import Foundation

enum ProductModuleID: String, CaseIterable, Codable, Identifiable {
    case insideAndOut
    case conversionCalculator
    case inTheKitchen
    case atTheShop
    case atTheGym
    case onTheRoad
    case hereToThere

    var id: String { rawValue }
}

enum ModuleAccessPolicy: Equatable {
    case includedInApp
    case comingSoon
    case inAppPurchase(productID: String?)
}

struct ProductModuleDefinition: Identifiable, Equatable {
    let id: ProductModuleID
    let title: String
    let subtitle: String?
    let access: ModuleAccessPolicy
    let unlockModule: AppModule?

    var isComingSoon: Bool {
        if case .comingSoon = access { return true }
        return false
    }
}

enum ModuleCatalog {
    static let learningHomeModules: [ProductModuleDefinition] = [
        ProductModuleDefinition(
            id: .insideAndOut,
            title: AppModule.insideAndOut.title,
            subtitle: AppModule.insideAndOut.subtitle,
            access: .includedInApp,
            unlockModule: .insideAndOut
        ),
        ProductModuleDefinition(
            id: .inTheKitchen,
            title: AppModule.inTheKitchen.title,
            subtitle: AppModule.inTheKitchen.subtitle,
            access: .includedInApp,
            unlockModule: .inTheKitchen
        ),
        ProductModuleDefinition(
            id: .atTheShop,
            title: AppModule.inTheShop.title,
            subtitle: AppModule.inTheShop.subtitle,
            access: .includedInApp,
            unlockModule: .inTheShop
        ),
        ProductModuleDefinition(
            id: .atTheGym,
            title: AppModule.atTheGym.title,
            subtitle: AppModule.atTheGym.subtitle,
            access: .includedInApp,
            unlockModule: .atTheGym
        ),
        ProductModuleDefinition(
            id: .onTheRoad,
            title: AppModule.onTheRoad.title,
            subtitle: AppModule.onTheRoad.subtitle,
            access: .includedInApp,
            unlockModule: .onTheRoad
        ),
        ProductModuleDefinition(
            id: .hereToThere,
            title: AppModule.hereToThere.title,
            subtitle: AppModule.hereToThere.subtitle,
            access: .includedInApp,
            unlockModule: .hereToThere
        ),
    ]

    static let conversionCalculator = ProductModuleDefinition(
        id: .conversionCalculator,
        title: AppModule.conversionCalculator.title,
        subtitle: AppModule.conversionCalculator.subtitle,
        access: .includedInApp,
        unlockModule: .conversionCalculator
    )

    static func definition(for id: ProductModuleID) -> ProductModuleDefinition? {
        if id == .conversionCalculator { return conversionCalculator }
        return learningHomeModules.first { $0.id == id }
    }

    static func isEntitled(
        _ id: ProductModuleID,
        unlockStore: ModuleUnlockStore,
        purchaseEntitlements: Set<ProductModuleID> = []
    ) -> Bool {
        guard let definition = definition(for: id) else { return false }
        switch definition.access {
        case .includedInApp:
            guard let unlockModule = definition.unlockModule else { return true }
            return unlockStore.isUnlocked(unlockModule)
        case .comingSoon:
            return false
        case .inAppPurchase:
            return purchaseEntitlements.contains(id)
                || (definition.unlockModule.map { unlockStore.isUnlocked($0) } ?? false)
        }
    }
}
