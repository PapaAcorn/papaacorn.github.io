//
//  KitchenConversionTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class KitchenConversionTests: XCTestCase {
    func testTeaspoonsToMilliliters() throws {
        let result = try ConversionEngine.convert(value: 2, from: .teaspoons, to: .milliliters, category: .kitchen).get()
        XCTAssertEqual(result, 9.86, accuracy: 0.05)
    }

    func testTablespoonsToTeaspoons() throws {
        let result = try ConversionEngine.convert(value: 1, from: .tablespoons, to: .teaspoons, category: .kitchen).get()
        XCTAssertEqual(result, 3, accuracy: 0.01)
    }

    func testGramsToLitersIsIncompatible() {
        let result = ConversionEngine.convert(value: 100, from: .grams, to: .liters, category: .kitchen)
        XCTAssertEqual(result, .failure(.incompatibleUnits))
    }

    func testCompatibilityBlocksCrossDimension() {
        XCTAssertFalse(ConversionUnitCompatibility.canConvert(from: .grams, to: .cups, category: .kitchen))
        XCTAssertTrue(ConversionUnitCompatibility.canConvert(from: .grams, to: .ounces, category: .kitchen))
        XCTAssertTrue(ConversionUnitCompatibility.canConvert(from: .cups, to: .milliliters, category: .kitchen))
    }
}
