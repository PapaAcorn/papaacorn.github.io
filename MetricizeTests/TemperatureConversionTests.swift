//
//  TemperatureConversionTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class TemperatureConversionTests: XCTestCase {
    func testEvaluateCloseEnoughWithinTolerance() {
        let result = TemperatureConversion.evaluate(guess: 54, target: 50, tolerance: 5)
        XCTAssertEqual(result, .closeEnough)
    }

    func testEvaluateIncorrectOutsideTolerance() {
        let result = TemperatureConversion.evaluate(guess: 54, target: 50, tolerance: 3)
        XCTAssertEqual(result, .incorrect)
    }

    func testEvaluateExact() {
        let result = TemperatureConversion.evaluate(guess: 50, target: 50, tolerance: 5)
        XCTAssertEqual(result, .exact)
    }
}
