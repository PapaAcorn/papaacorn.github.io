//
//  ComingSoonModule.swift
//  Metricize
//

import Foundation

enum ComingSoonModule: CaseIterable, Identifiable {
    case inTheKitchen
    case atTheGym
    case onTheRoad
    case hereToThere

    var id: String { title }

    var title: String {
        switch self {
        case .inTheKitchen: "In the Kitchen"
        case .atTheGym: "At the gym"
        case .onTheRoad: "On the Road"
        case .hereToThere: "Here to There"
        }
    }

    var subtitle: String {
        switch self {
        case .inTheKitchen: "Cooking Temps and Measurements"
        case .atTheGym: "Heavy Weights and Treadmill Speeds"
        case .onTheRoad: "Speed and Map Distance"
        case .hereToThere: "Distance by Vibe"
        }
    }
}

enum ModuleTileItem: Identifiable {
    case insideAndOut
    case conversionCalculator
    case comingSoon(ComingSoonModule)

    var id: String {
        switch self {
        case .insideAndOut: "inside-and-out"
        case .conversionCalculator: "conversion-calculator"
        case .comingSoon(let module): module.id
        }
    }

    var title: String {
        switch self {
        case .insideAndOut: AppModule.insideAndOut.title
        case .conversionCalculator: AppModule.conversionCalculator.title
        case .comingSoon(let module): module.title
        }
    }

    var subtitle: String? {
        switch self {
        case .insideAndOut: AppModule.insideAndOut.subtitle
        case .conversionCalculator: AppModule.conversionCalculator.subtitle
        case .comingSoon(let module): module.subtitle
        }
    }

    static var homeGrid: [ModuleTileItem] {
        [.insideAndOut, .conversionCalculator] + ComingSoonModule.allCases.map { .comingSoon($0) }
    }
}
