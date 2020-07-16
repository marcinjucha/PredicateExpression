import XCTest
import Foundation
@testable import PredicateExpression

final class PredicateExpressionRawElementTests: XCTestCase {
    let values = (0 ... 100).map { _ in Int.random(in: 0 ... 1000) }

    func test_Ints_BasicComparison() {
        let value = values[50]

        verify(expression: .selfKey == value, comparison: { $0 == value })
        verify(expression: .selfKey != value, comparison: { $0 != value })
        verify(expression: .selfKey > value, comparison: { $0 > value})
        verify(expression: .selfKey < value, comparison: { $0 < value})
    }

    private func verify(expression: PredicateExpression, comparison: @escaping (Int) -> Bool, file: StaticString = #file, line: UInt = #line) {
        NSPredicate(expression)
            .verify(values, comparison: comparison, file: file, line: line)
    }
}