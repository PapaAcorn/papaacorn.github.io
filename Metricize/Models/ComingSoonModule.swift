//
//  ComingSoonModule.swift
//  Metricize
//

import Foundation

enum ComingSoonModule: CaseIterable, Identifiable {
    case inTheKitchen
    case hereToThere
    case onTheRoad
    case atTheGym
    case conversionCalculator

    var id: String { title }

    var title: String {
        switch self {
        case .inTheKitchen: "In the Kitchen"
        case .hereToThere: "Here to There"
        case .onTheRoad: "On the Road"
        case .atTheGym: "At the gym"
        case .conversionCalculator: "Conversion Calculator"
        }
    }

    var subtitle: String {
        switch self {
        case .inTheKitchen: "Cooking Temps and Measurements"
        case .hereToThere: "Distance by Vibe"
        case .onTheRoad: "Speed and Map Distance"
        case .atTheGym: "Heavy Weights and Treadmill Speeds"
        case .conversionCalculator: "You'll need it eventually."
        }
    }

    var systemImage: String {
        switch self {
        case .inTheKitchen: "frying.pan.fill"
        case .hereToThere: "map.fill"
        case .onTheRoad: "car.fill"
        case .atTheGym: "dumbbell.fill"
        case .conversionCalculator: "function"
        }
    }
}
