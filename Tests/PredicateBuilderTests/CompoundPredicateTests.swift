import Foundation
import XCTest
@testable import PredicateBuilder

class CompoundPredicateTests: XCTestCase {
  
  lazy var sut = data.test
  private let data = PersonTestData()
  
  func test_LogicalTypeAnd_WithNameAndAge() {
    let name = ".+a."
    let age = 50
    
    CompoundPredicate(
      type: .and,
      subpredicates: [
        Predicate(key: #keyPath(Person.name), value: name, comparison: .matches),
        Predicate(key: #keyPath(Person.age), value: age, comparison: .lessEqual)
    ])
      .predicate
      .verify(sut,
              filterHandler: { $0.age <= age && $0.name[suffix: 2].first == "a" })
  }
  
  func test_LogicalTypeOr_WithNameAndAge() {
    let name = ".+a."
    let age = 50
    
    CompoundPredicate(
      type: .or,
      subpredicates: [
        Predicate(key: #keyPath(Person.name), value: name, comparison: .matches),
        Predicate(key: #keyPath(Person.age), value: age, comparison: .lessEqual)
    ])
      .predicate
      .verify(sut,
              filterHandler: { $0.age <= age || $0.name[suffix: 2].first == "a" })
  }
}
