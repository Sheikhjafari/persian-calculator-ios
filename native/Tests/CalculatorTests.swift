import XCTest
import Foundation
@testable import CalculatorCore

final class CalculatorTests: XCTestCase {
    struct Fixture: Decodable {
        let keys: [String]
        let value: String
        let expression: String
        let fresh: Bool
        let operation: String?
        let left: String?
    }
    func testMatchesWebCalculator() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "fixtures", withExtension: "json"))
        let fixtures = try JSONDecoder().decode([Fixture].self, from: Data(contentsOf: url))
        for fixture in fixtures {
            var calculator = Calculator()
            for key in fixture.keys { calculator.press(key) }
            let context = fixture.keys.joined(separator: " ")
            XCTAssertEqual(calculator.value, fixture.value, context)
            XCTAssertEqual(calculator.expression, fixture.expression, context)
            XCTAssertEqual(calculator.fresh, fixture.fresh, context)
            XCTAssertEqual(calculator.operation, fixture.operation, context)
            XCTAssertEqual(calculator.left, fixture.left, context)
        }
    }
    func testExactArithmetic() {
        XCTAssertEqual(Calculator.calculate("0.1", "0.2", "+"), "0.3")
        XCTAssertEqual(Calculator.calculate("1", "1.001", "-"), "-0.001")
        XCTAssertEqual(Calculator.calculate("-0", "0", "+"), "0")
        XCTAssertEqual(Calculator.calculate("999999999999999999", "1", "+"), "1000000000000000000")
        XCTAssertEqual(Calculator.calculate("-2.05", "-3.1", "-"), "1.05")
    }
}
