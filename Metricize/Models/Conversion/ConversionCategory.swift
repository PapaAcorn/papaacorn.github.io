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
    case construction
    case kitchen

    var id: String { rawValue }

    /// Category groups for the picker menu, with Construction and Kitchen separated.
    static let pickerSections: [[ConversionCategory]] = [
        [.temperature, .distance, .volume, .weight, .speed],
        [.construction, .kitchen],
    ]

    var displayName: String {
        switch self {
        case .temperature: "Temperature"
        case .distance: "Distance"
        case .construction: "Construction"
        case .kitchen: "Kitchen"
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
        case .construction:
            [.inchesFraction, .feetFraction, .millimeters, .centimeters, .meters]
        case .kitchen:
            [.teaspoons, .tablespoons, .fluidOunces, .cups, .milliliters, .liters, .pints, .grams, .ounces]
        case .volume:
            [.fluidOunces, .milliliters, .cups, .liters, .pints, .quarts, .gallons]
        case .weight:
            [.ounces, .grams, .pounds, .kilograms, .stones]
        case .speed:
            [.milesPerHour, .kilometersPerHour, .feetPerSecond, .metersPerSecond]
        }
    }

    /// Units shown in portrait; remaining units appear in landscape.
    var portraitUnits: [ConversionUnit] {
        switch self {
        case .temperature:
            [.fahrenheit, .celsius, .gasMark]
        case .distance:
            [.inches, .millimeters, .centimeters, .feet, .meters, .miles, .kilometers]
        case .construction:
            [.inchesFraction, .millimeters, .centimeters]
        case .kitchen:
            [.teaspoons, .tablespoons, .cups, .milliliters, .fluidOunces, .grams, .liters, .ounces]
        case .volume:
            [.fluidOunces, .milliliters, .cups, .liters, .pints, .gallons]
        case .weight:
            [.ounces, .grams, .pounds, .kilograms, .stones]
        case .speed:
            [.milesPerHour, .kilometersPerHour]
        }
    }

    var landscapeOnlyUnits: [ConversionUnit] {
        Set(units).subtracting(portraitUnits).sorted { $0.displayName < $1.displayName }
    }

    var hasLandscapeExtras: Bool {
        !landscapeOnlyUnits.isEmpty
    }
}
