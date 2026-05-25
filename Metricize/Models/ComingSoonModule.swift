//
//  ComingSoonModule.swift
//  Metricize
//

import Foundation

enum ComingSoonModule: CaseIterable, Identifiable {
    case inTheKitchen
    case hereToThere

    var id: String { title }

    var title: String {
        switch self {
        case .inTheKitchen: "In the Kitchen"
        case .hereToThere: "Here to There"
        }
    }

    var subtitle: String {
        switch self {
        case .inTheKitchen: "Cooking Temps and Measurements"
        case .hereToThere: "Distance by Vibe"
        }
    }

    var systemImage: String {
        switch self {
        case .inTheKitchen: "frying.pan.fill"
        case .hereToThere: "map.fill"
        }
    }
}
