import Foundation
import XCTest

extension NSPredicate {

  func verify<T: Equatable>(_ array: [T],
                            filterHandler: (T) -> Bool,
                            file: StaticString = #file,
                            line: UInt = #line) {
    let resultArray = array.filter(using: self)
    let expectedArray = array.filter(filterHandler)

    XCTAssertEqual(resultArray.count, expectedArray.count, file: file, line: line)
//    XCTAssertEqual(resultArray, expectedArray, file: file, line: line)
  }
}
