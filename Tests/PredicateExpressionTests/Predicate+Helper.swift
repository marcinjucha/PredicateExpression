import Foundation
import XCTest

extension NSPredicate {

    @discardableResult
    func verify<T: Equatable>(_ array: [T], filterHandler: (T) -> Bool, file: StaticString = #file, line: UInt = #line) -> Self {
        let resultArray = array.filter(using: self)
        let expectedArray = array.filter(filterHandler)

        XCTAssertEqual(expectedArray.count, resultArray.count, file: file, line: line)
        XCTAssertEqual(expectedArray, resultArray, file: file, line: line)

        return self
    }

    @discardableResult
    func verify(predicate: NSPredicate, file: StaticString = #file, line: UInt = #line) -> Self {
        print("\(predicate) *** \(self)")

        XCTAssertEqual(predicate, self, "Invalid composition", file: file, line: line)

        return self
    }
}
