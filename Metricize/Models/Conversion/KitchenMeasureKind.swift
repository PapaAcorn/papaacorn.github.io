//
//  KitchenMeasureKind.swift
//  Metricize
//

import Foundation

enum KitchenMeasureKind: String, Codable, Hashable {
    case volume
    case weight
}

enum ConversionUnitCompatibility {
    static func canConvert(from source: ConversionUnit, to target: ConversionUnit, category: ConversionCategory) -> Bool {
        switch category {
        case .kitchen:
            guard let sourceKind = source.kitchenMeasureKind, let targetKind = target.kitchenMeasureKind else {
                return false
            }
            return sourceKind == targetKind
        case .construction:
            return ConversionEngine.isLengthCompatible(source, target)
        default:
            if source.primaryCategory == target.primaryCategory { return true }
            return ConversionEngine.isLengthCompatible(source, target)
        }
    }

    static func compatibleTargets(from source: ConversionUnit, in category: ConversionCategory, available: [ConversionUnit]) -> [ConversionUnit] {
        available.filter { $0 != source && canConvert(from: source, to: $0, category: category) }
    }
}
