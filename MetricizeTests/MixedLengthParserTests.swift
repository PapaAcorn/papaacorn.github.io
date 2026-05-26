//
//  MixedLengthParserTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class MixedLengthParserTests: XCTestCase {
    func testFeetAndInchesWords() throws {
        let meters = try MixedLengthParser.parseToMeters("5 ft 10 in", defaultUnit: .feet).get()
        XCTAssertEqual(meters, 1.778, accuracy: 0.001)
    }

    func testFeetInchesCommaShortcut() throws {
        let meters = try MixedLengthParser.parseToMeters("5, 10", defaultUnit: .feet).get()
        XCTAssertEqual(meters, 1.778, accuracy: 0.001)
    }

    func testFeetInchesWithUnitWords() throws {
        let meters = try MixedLengthParser.parseToMeters("5 feet, 10 inches", defaultUnit: .feet).get()
        XCTAssertEqual(meters, 1.778, accuracy: 0.001)
    }

    func testMixedLengthConversionToInches() throws {
        let conversion = try ConversionEngine.convert(input: "5 ft 10 in", from: .feet, to: .inches).get()
        XCTAssertEqual(conversion.numericValue, 70, accuracy: 0.01)
    }

    func testMixedLengthCommaConversionToMillimeters() throws {
        let conversion = try ConversionEngine.convert(input: "5, 10", from: .feet, to: .millimeters, category: .distance).get()
        XCTAssertEqual(conversion.numericValue, 1778, accuracy: 1)
    }
}
