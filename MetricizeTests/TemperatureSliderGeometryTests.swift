//
//  TemperatureSliderGeometryTests.swift
//  MetricizeTests
//

import CoreGraphics
import XCTest
@testable import Metricize

final class TemperatureSliderGeometryTests: XCTestCase {
    func testCompactSliderReachesFullCelsiusRange() {
        let range = Double(TemperatureGameConstants.celsiusMin)...Double(TemperatureGameConstants.celsiusMax)
        let height: CGFloat = 180
        let bounds = TemperatureSliderGeometry.dragBounds(in: height)

        let coldest = TemperatureSliderGeometry.value(at: bounds.upperBound, in: range, height: height)
        let warmest = TemperatureSliderGeometry.value(at: bounds.lowerBound, in: range, height: height)

        XCTAssertEqual(coldest.rounded(), Double(TemperatureGameConstants.celsiusMin))
        XCTAssertEqual(warmest.rounded(), Double(TemperatureGameConstants.celsiusMax))
    }

    func testZeroFahrenheitAnswerIsReachableOnCompactSlider() {
        let target = Double(TemperatureConversion.celsius(fromFahrenheit: 0))
        XCTAssertEqual(target, -18)

        let range = Double(TemperatureGameConstants.celsiusMin)...Double(TemperatureGameConstants.celsiusMax)
        let height: CGFloat = 180
        let bounds = TemperatureSliderGeometry.dragBounds(in: height)
        let coldestReachable = TemperatureSliderGeometry.value(at: bounds.upperBound, in: range, height: height)

        XCTAssertLessThanOrEqual(coldestReachable, target)

        let targetY = TemperatureSliderGeometry.yPosition(for: target, in: range, height: height)
        XCTAssertTrue(bounds.contains(targetY))

        let restored = TemperatureSliderGeometry.value(at: targetY, in: range, height: height)
        XCTAssertEqual(restored.rounded(), target)
    }

    func testCompactSliderReachesNegativeFahrenheit() {
        let range = Double(TemperatureGameConstants.fahrenheitMin)...Double(TemperatureGameConstants.fahrenheitMax)
        let height: CGFloat = 180
        let bounds = TemperatureSliderGeometry.dragBounds(in: height)

        let coldest = TemperatureSliderGeometry.value(at: bounds.upperBound, in: range, height: height)
        XCTAssertEqual(coldest.rounded(), Double(TemperatureGameConstants.fahrenheitMin))

        let minusFour = TemperatureSliderGeometry.yPosition(for: -4, in: range, height: height)
        XCTAssertTrue(bounds.contains(minusFour))
    }
}
