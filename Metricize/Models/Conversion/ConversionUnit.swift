//
//  ConversionUnit.swift
//  Metricize
//

import Foundation

enum ConversionUnit: String, CaseIterable, Identifiable, Codable, Hashable {
    // Temperature
    case fahrenheit
    case celsius
    case gasMark

    // Distance
    case inches
    case millimeters
    case centimeters
    case feet
    case meters
    case yards
    case miles
    case kilometers

    // Volume
    case teaspoons
    case tablespoons
    case fluidOunces
    case milliliters
    case cups
    case liters
    case pints
    case quarts
    case gallons

    // Weight
    case ounces
    case grams
    case pounds
    case kilograms
    case stones

    // Speed
    case milesPerHour
    case kilometersPerHour
    case feetPerSecond
    case metersPerSecond

    var id: String { rawValue }

    var primaryCategory: ConversionCategory {
        switch self {
        case .fahrenheit, .celsius, .gasMark:
            .temperature
        case .inches, .millimeters, .centimeters, .feet, .meters, .yards, .miles, .kilometers:
            .distance
        case .teaspoons, .tablespoons, .fluidOunces, .milliliters, .cups, .liters, .pints, .quarts, .gallons:
            .volume
        case .ounces, .grams, .pounds, .kilograms, .stones:
            .weight
        case .milesPerHour, .kilometersPerHour, .feetPerSecond, .metersPerSecond:
            .speed
        }
    }

    var category: ConversionCategory { primaryCategory }

    var displayName: String {
        switch self {
        case .fahrenheit: "Fahrenheit"
        case .celsius: "Celsius"
        case .gasMark: "Gas Mark"
        case .inches: "Inches"
        case .millimeters: "Millimeters"
        case .centimeters: "Centimeters"
        case .feet: "Feet"
        case .meters: "Meters"
        case .yards: "Yards"
        case .miles: "Miles"
        case .kilometers: "Kilometers"
        case .teaspoons: "Teaspoons"
        case .tablespoons: "Tablespoons"
        case .fluidOunces: "Fluid Ounces"
        case .milliliters: "Milliliters"
        case .cups: "Cups"
        case .liters: "Liters"
        case .pints: "Pints"
        case .quarts: "Quarts"
        case .gallons: "Gallons"
        case .ounces: "Ounces"
        case .grams: "Grams"
        case .pounds: "Pounds"
        case .kilograms: "Kilograms"
        case .stones: "Stones"
        case .milesPerHour: "Miles per Hour"
        case .kilometersPerHour: "Kilometers per Hour"
        case .feetPerSecond: "Feet per Second"
        case .metersPerSecond: "Meters per Second"
        }
    }

    var symbol: String {
        switch self {
        case .fahrenheit: "°F"
        case .celsius: "°C"
        case .gasMark: "Gas"
        case .inches: "in"
        case .millimeters: "mm"
        case .centimeters: "cm"
        case .feet: "ft"
        case .meters: "m"
        case .yards: "yd"
        case .miles: "mi"
        case .kilometers: "km"
        case .teaspoons: "tsp"
        case .tablespoons: "tbsp"
        case .fluidOunces: "fl oz"
        case .milliliters: "mL"
        case .cups: "cup"
        case .liters: "L"
        case .pints: "pt"
        case .quarts: "qt"
        case .gallons: "gal"
        case .ounces: "oz"
        case .grams: "g"
        case .pounds: "lb"
        case .kilograms: "kg"
        case .stones: "st"
        case .milesPerHour: "mph"
        case .kilometersPerHour: "km/h"
        case .feetPerSecond: "ft/s"
        case .metersPerSecond: "m/s"
        }
    }

    var acceptsFractions: Bool {
        switch self {
        case .inches, .feet: true
        default: false
        }
    }

    static func units(for category: ConversionCategory) -> [ConversionUnit] {
        category.units
    }
}

extension ConversionUnit {
    var isImperialLength: Bool {
        switch self {
        case .inches, .feet, .yards, .miles: true
        default: false
        }
    }
}
