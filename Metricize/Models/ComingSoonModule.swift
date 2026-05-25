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
    case conversionCalculator

    var id: String { title }

    var title: String {
        switch self {
        case .inTheKitchen: "In the Kitchen"
        case .atTheGym: "At the gym"
        case .onTheRoad: "On the Road"
        case .hereToThere: "Here to There"
        case .conversionCalculator: "Conversion Calculator"
        }
    }

    var subtitle: String {
        switch self {
        case .inTheKitchen: "Cooking Temps and Measurements"
        case .atTheGym: "Heavy Weights and Treadmill Speeds"
        case .onTheRoad: "Speed and Map Distance"
        case .hereToThere: "Distance by Vibe"
        case .conversionCalculator: "You'll need it eventually."
        }
    }
}

enum ModuleTileItem: Identifiable {
    case insideAndOut
    case comingSoon(ComingSoonModule)

    var id: String {
        switch self {
        case .insideAndOut: "inside-and-out"
        case .comingSoon(let module): module.id
        }
    }

    var title: String {
        switch self {
        case .insideAndOut: AppModule.insideAndOut.title
        case .comingSoon(let module): module.title
        }
    }

    var subtitle: String? {
        switch self {
        case .insideAndOut: AppModule.insideAndOut.subtitle
        case .comingSoon(let module): module.subtitle
        }
    }

    static var homeGrid: [ModuleTileItem] {
        [.insideAndOut] + ComingSoonModule.allCases.map { .comingSoon($0) }
    }
}
