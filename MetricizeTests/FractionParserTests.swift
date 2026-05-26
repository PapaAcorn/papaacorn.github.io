//
//  FractionParserTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class FractionParserTests: XCTestCase {
    func testSimpleFraction() throws {
        let result = try FractionParser.parse("7/8").get()
        XCTAssertEqual(result, 0.875, accuracy: 0.0001)
    }

    func testMixedNumberThreeAndThreeThirtySeconds() throws {
        let result = try FractionParser.parse("3 3/32").get()
        XCTAssertEqual(result, 3.09375, accuracy: 0.00001)
    }

    func testMixedNumberFourAndOneSixteenth() throws {
        let result = try FractionParser.parse("4 1/16").get()
        XCTAssertEqual(result, 4.0625, accuracy: 0.00001)
    }

    func testMixedNumberTwelveAndSevenSixtyFourths() throws {
        let result = try FractionParser.parse("12 7/64").get()
        XCTAssertEqual(result, 12.109375, accuracy: 0.00001)
    }

    func testDecimalInput() throws {
        let result = try FractionParser.parse("3.5").get()
        XCTAssertEqual(result, 3.5, accuracy: 0.0001)
    }

    func testOneAndOneHalf() throws {
        let result = try FractionParser.parse("1 1/2").get()
        XCTAssertEqual(result, 1.5, accuracy: 0.0001)
    }

    func testMalformedFractionReturnsError() {
        XCTAssertEqual(FractionParser.parse("3/"), .failure(.invalidFormat))
        XCTAssertEqual(FractionParser.parse("abc"), .failure(.invalidFormat))
    }

    func testFormatInchesFraction() {
        XCTAssertEqual(FractionParser.formatInchesFraction(3.09375), "3 3/32")
        XCTAssertEqual(FractionParser.formatInchesFraction(0.875), "7/8")
    }
}
