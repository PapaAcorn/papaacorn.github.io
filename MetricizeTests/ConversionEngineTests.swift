//
//  ConversionEngineTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class ConversionEngineTests: XCTestCase {
    func testFahrenheitToCelsius() throws {
        let result = try ConversionEngine.convert(value: 72, from: .fahrenheit, to: .celsius).get()
        XCTAssertEqual(result, 22.222, accuracy: 0.05)
    }

    func testCelsiusToFahrenheit() throws {
        let result = try ConversionEngine.convert(value: 100, from: .celsius, to: .fahrenheit).get()
        XCTAssertEqual(result, 212, accuracy: 0.1)
    }

    func testInchesToMillimeters() throws {
        let result = try ConversionEngine.convert(value: 1, from: .inches, to: .millimeters).get()
        XCTAssertEqual(result, 25.4, accuracy: 0.01)
    }

    func testMixedFractionInchesToMillimeters() throws {
        let conversion = try ConversionEngine.convert(input: "3 3/32", from: .inchesFraction, to: .millimeters).get()
        XCTAssertEqual(conversion.numericValue, 78.58125, accuracy: 0.01)
        XCTAssertTrue(conversion.copyableOutput.contains("mm"))
    }

    func testMilesToKilometers() throws {
        let result = try ConversionEngine.convert(value: 10, from: .miles, to: .kilometers).get()
        XCTAssertEqual(result, 16.0934, accuracy: 0.01)
    }

    func testMPHToKMH() throws {
        let result = try ConversionEngine.convert(value: 60, from: .milesPerHour, to: .kilometersPerHour).get()
        XCTAssertEqual(result, 96.5606, accuracy: 0.05)
    }

    func testPoundsToKilograms() throws {
        let result = try ConversionEngine.convert(value: 150, from: .pounds, to: .kilograms).get()
        XCTAssertEqual(result, 68.0388, accuracy: 0.01)
    }

    func testGallonsToLiters() throws {
        let result = try ConversionEngine.convert(value: 2, from: .gallons, to: .liters).get()
        XCTAssertEqual(result, 7.57082, accuracy: 0.01)
    }

    func testStonesToKilograms() throws {
        let result = try ConversionEngine.convert(value: 10, from: .stones, to: .kilograms).get()
        XCTAssertEqual(result, 63.5029, accuracy: 0.01)
    }
}
