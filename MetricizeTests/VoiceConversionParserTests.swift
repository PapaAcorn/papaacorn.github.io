//
//  VoiceConversionParserTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class VoiceConversionParserTests: XCTestCase {
    func testSpokenMixedFraction() {
        let parsed = VoiceConversionParser.parseSpokenNumber("three and three thirty-seconds")
        XCTAssertEqual(parsed, "3 3/32")
    }

    func testParseFahrenheitToCelsiusPhrase() {
        let request = VoiceConversionParser.parse("Convert 72 Fahrenheit to Celsius")
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.sourceUnit, .fahrenheit)
        XCTAssertEqual(request?.targetUnit, .celsius)
        XCTAssertEqual(request?.inputText, "72")
    }

    func testParseMilesToKilometersPhrase() {
        let request = VoiceConversionParser.parse("Convert five miles to kilometers")
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.sourceUnit, .miles)
        XCTAssertEqual(request?.targetUnit, .kilometers)
    }
}
