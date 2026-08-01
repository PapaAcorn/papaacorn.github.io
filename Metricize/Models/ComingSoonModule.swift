//
//  ComingSoonModule.swift
//  Metricize
//

import Foundation

enum ModuleTileItem: Identifiable {
    case product(ProductModuleDefinition)

    var id: String {
        switch self {
        case .product(let definition): definition.id.rawValue
        }
    }

    var title: String {
        switch self {
        case .product(let definition): definition.title
        }
    }

    var subtitle: String? {
        switch self {
        case .product(let definition): definition.subtitle
        }
    }

    var productID: ProductModuleID {
        switch self {
        case .product(let definition): definition.id
        }
    }

    var isComingSoon: Bool {
        switch self {
        case .product(let definition): definition.isComingSoon
        }
    }

    static var learningGrid: [ModuleTileItem] {
        ModuleCatalog.learningHomeModules.map { .product($0) }
    }
}
