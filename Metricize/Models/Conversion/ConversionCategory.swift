//
//  ConversionCategory.swift
//  Metricize
//

import Foundation

enum ConversionCategory: String, CaseIterable, Identifiable, Codable {
    case temperature
    case distance
    case volume
    case weight
    case speed

    var id: String { rawValue }

    static let pickerOrder: [ConversionCategory] = [
        .temperature, .distance, .volume, .weight, .speed,
    ]

    var displayName: String {
        switch self {
        case .temperature: "Temperature"
        case .distance: "Distance"
        case .volume: "Volume"
        case .weight: "Weight"
        case .speed: "Speed"
        }
    }

    var units: [ConversionUnit] {
        switch self {
        case .temperature:
            [.fahrenheit, .celsius, .gasMark]
        case .distance:
            [.inches, .millimeters, .centimeters, .feet, .meters, .yards, .miles, .kilometers]
        case .volume:
            [.teaspoons, .tablespoons, .fluidOunces, .milliliters, .cups, .liters, .pints, .quarts, .gallons]
        case .weight:
            [.ounces, .grams, .pounds, .kilograms, .stones]
        case .speed:
            [.milesPerHour, .kilometersPerHour, .feetPerSecond, .metersPerSecond]
        }
    }
}
