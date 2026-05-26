//
//  UnitCalculatorViewModelTests.swift
//  MetricizeTests
//

import XCTest
@testable import Metricize

final class UnitCalculatorViewModelTests: XCTestCase {
    func testFractionEntryParsesMixedNumber() {
        let viewModel = UnitCalculatorViewModel(category: .construction, unit: .inchesFraction)
        viewModel.clear()
        viewModel.appendDigit("1")
        viewModel.appendDigit("0")
        viewModel.appendSpace()
        viewModel.appendDigit("1")
        viewModel.appendSlash()
        viewModel.appendDigit("2")

        XCTAssertEqual(viewModel.display, "10 1/2")
        XCTAssertEqual(viewModel.numericValue ?? 0, 10.5, accuracy: 0.0001)
        XCTAssertEqual(viewModel.converterValue, "10 1/2")
    }

    func testFractionAddition() {
        let viewModel = UnitCalculatorViewModel(category: .construction, unit: .inchesFraction)
        viewModel.clear()
        viewModel.appendDigit("1")
        viewModel.appendSlash()
        viewModel.appendDigit("2")
        viewModel.applyOperation(.add)
        viewModel.appendDigit("1")
        viewModel.appendSlash()
        viewModel.appendDigit("4")
        viewModel.equals()

        XCTAssertEqual(viewModel.numericValue ?? 0, 0.75, accuracy: 0.0001)
    }

    func testFractionToggle() {
        let viewModel = UnitCalculatorViewModel(category: .construction, unit: .inchesFraction)
        viewModel.clear()
        viewModel.appendDigit("1")
        viewModel.appendDecimal()
        viewModel.appendDigit("5")
        viewModel.toggleFractionDecimal()

        XCTAssertEqual(viewModel.displayMode, .fraction)
        XCTAssertTrue(viewModel.display.contains("/"))

        viewModel.toggleFractionDecimal()
        XCTAssertEqual(viewModel.displayMode, .decimal)
        XCTAssertEqual(viewModel.numericValue ?? 0, 1.5, accuracy: 0.0001)
    }
}
