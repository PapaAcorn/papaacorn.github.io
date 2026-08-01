//
//  ConversionUnitCompatibility.swift
//  Metricize
//

import Foundation

enum ConversionUnitCompatibility {
    static func canConvert(from source: ConversionUnit, to target: ConversionUnit, category: ConversionCategory) -> Bool {
        if source.primaryCategory == target.primaryCategory { return true }
        return ConversionEngine.isLengthCompatible(source, target)
    }

    static func compatibleTargets(
        from source: ConversionUnit,
        in category: ConversionCategory,
        available: [ConversionUnit]
    ) -> [ConversionUnit] {
        available.filter { $0 != source && canConvert(from: source, to: $0, category: category) }
    }
}
