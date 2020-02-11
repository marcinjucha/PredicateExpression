import XCTest
import Foundation
@testable import PredicateBuilder

class PredicateTests: XCTestCase {
  lazy var sut: [Person] = data.test
  private let data = PersonTestData()

  func test_ComparisonEqual_Name() {
    let name = data.maleNames.randomElement()!
    Predicate(key: #keyPath(Person.name),
              value: name,
              comparison: .equal)
      .predicate
      .verify(sut,
              filterHandler: { $0.name == name })

  }

  func test_ComparisonEqual_PartnerName() {
    let name = data.femaleNames.randomElement()!
    Predicate(key: #keyPath(Person.partner.name),
              value: name,
              comparison: .equal)
      .predicate
      .verify(sut,
              filterHandler: { $0.partner.name == name })

  }

  func test_ComparisonGreaterEqual_AgeGreaterEqual40() {
    let age = 40
    Predicate(key: #keyPath(Person.age),
              value: age,
              comparison: .greaterEqual)
      .predicate
      .verify(sut,
              filterHandler: { $0.age >= age })

  }

  func test_ComparisonGreaterEqual_AggregateAny_ChildrenAge() {
    let age = 13
    Predicate(key: #keyPath(Person.children.age),
              value: age,
              comparison: .greaterEqual,
              aggregate: .any)
      .predicate
      .verify(sut,
              filterHandler: { $0.children.filter { $0.age >= age }.count > 0 })

  }

  func test_ComparisonGreater_AggregateAny_ChildrenAge() {
    let age = 13
    Predicate(key: #keyPath(Person.children.age),
              value: age,
              comparison: .greater,
              aggregate: .any)
      .predicate
      .verify(sut,
              filterHandler: { $0.children.filter { $0.age > age }.count > 0 })

  }

  func test_ComparisonLessThan_AggregateAny_ChildrenAge() {
    let age = 7
    Predicate(key: #keyPath(Person.children.age),
              value: age,
              comparison: .lessEqual,
              aggregate: .any)
      .predicate
      .verify(sut,
              filterHandler: { $0.children.filter { $0.age <= age }.count > 0 })

  }

  func test_ComparisonLess_AggregateAny_ChildrenAge() {
    let age = 7
    Predicate(key: #keyPath(Person.children.age),
              value: age,
              comparison: .less,
              aggregate: .any)
      .predicate
      .verify(sut,
              filterHandler: { $0.children.filter { $0.age < age }.count > 0 })

  }

  func test_ComparisonNotEqual_AggregateAll_ChildrenAge() {
    let age = 10
    Predicate(key: #keyPath(Person.children.age),
              value: age,
              comparison: .notEqual,
              aggregate: .all)
      .predicate
      .verify(sut,
              filterHandler: { $0.children.filter { $0.age == age }.count == 0 })

  }

  func test_ComparisonBetween_AggregateAll_ChildrenAge() {
    let lower = 7
    let upper = 13
    Predicate(key: #keyPath(Person.children.age),
              value: [lower, upper],
              comparison: .between,
              aggregate: .all)
      .predicate
      .verify(sut,
              filterHandler: { $0.children.filter { $0.age < lower || $0.age > upper }.count == 0 })

  }

  func test_ComparisonIn_AggregateAll_ChildrenAge() {
    let numbers = [7, 9, 10, 11, 13]
    Predicate(key: #keyPath(Person.children.age),
              value: numbers,
              comparison: .in,
              aggregate: .all)
      .predicate
      .verify(sut,
              filterHandler: { $0.children.filter { numbers.contains($0.age) == false }.count == 0 })

  }

  func test_ComparisonIn_AggregateNotAny_ChildrenAge() {
    let numbers = [10, 11, 13]
    Predicate(key: #keyPath(Person.children.age),
              value: numbers,
              comparison: .in,
              aggregate: .notAny)
      .predicate
      .verify(sut,
              filterHandler: { $0.children.filter { numbers.contains($0.age) }.count == 0 })

  }

  func test_ComparisonLess_AggregateNotAny_ChildrenAge() {
    let age = 8
    Predicate(key: #keyPath(Person.children.age),
              value: age,
              comparison: .less,
              aggregate: .notAny)
      .predicate
      .verify(sut,
              filterHandler: { $0.children.filter { $0.age < age }.count == 0 })

  }

  func test_ComparisonBeginsWith_Name() {
    let name = data.maleNames.randomElement()!
    let prefix = name[prefix: 2]
    Predicate(key: #keyPath(Person.name),
              value: prefix,
              comparison: .beginsWith)
      .predicate
      .verify(sut,
              filterHandler: { $0.name.hasPrefix(prefix) })

  }

  func test_ComparisonContains_Name() {
    let namePart = "le"
    Predicate(key: #keyPath(Person.name),
              value: namePart,
              comparison: .contains)
      .predicate
      .verify(sut,
              filterHandler: { $0.name.contains(namePart) })

  }

  func test_ComparisonEndsWith_Name() {
    let name = data.femaleNames.randomElement()!
    let suffix = name[suffix: 2]
    Predicate(key: #keyPath(Person.name),
              value: suffix,
              comparison: .endsWith)
      .predicate
      .verify(sut,
              filterHandler: { $0.name.hasSuffix(suffix) })

  }

  func test_ComparisonLike_Name() {
    let char = ["a", "i", "e", "l"].randomElement()!
    let name = "*\(char)?"
    Predicate(key: #keyPath(Person.name),
              value: name,
              comparison: .like)
      .predicate
      .verify(sut,
              filterHandler: { $0.name[value: $0.name.count - 2] == char })

  }

  func test_ComparisonMatches_Name() {
    let regex = ".*ll?.*"
    Predicate(key: #keyPath(Person.name),
              value: regex,
              comparison: .matches)
      .predicate
      .verify(sut,
              filterHandler: { $0.name.range(of: regex, options: .regularExpression) != nil })

  }

  func test_ComparisonEqual_SELF() {
    let name = data.femaleNames.randomElement()!

    let predicate = Predicate(value: name, comparison: .equal).predicate

    let expected = #"SELF == "\#(name)""#
    XCTAssertEqual(expected, predicate.description)
  }

  func test_CaseInsensitiveOption_Name() {
    let name = data.femaleNames.randomElement()!.uppercased()[prefix: 2]

    let predicate = Predicate(key: #keyPath(Person.name),
                              value: name,
                              comparison: .contains,
                              options: [.caseInsensitive]).predicate

    let expected = #"name CONTAINS[c] "\#(name)""#
    XCTAssertEqual(expected, predicate.description)
  }

  func test_DiacriticInsensitiveOption_Name() {
    let name = data.femaleNames.randomElement()!.uppercased()[prefix: 2]

    let predicate = Predicate(key: #keyPath(Person.name),
                              value: name,
                              comparison: .contains,
                              options: [.diacriticInsensitive]).predicate

    let expected = #"name CONTAINS[d] "\#(name)""#
    XCTAssertEqual(expected, predicate.description)
  }

  func test_NormalizedOption_Name() {
    let name = data.femaleNames.randomElement()!.uppercased()[prefix: 2]

    let predicate = Predicate(key: #keyPath(Person.name),
                              value: name,
                              comparison: .contains,
                              options: [.normalized]).predicate

    let expected = #"name CONTAINS[n] "\#(name)""#
    XCTAssertEqual(expected, predicate.description)
  }

  func test_LocaleSensitiveOption_Name() {
    let name = data.femaleNames.randomElement()!.uppercased()[prefix: 2]

    let predicate = Predicate(key: #keyPath(Person.name),
                              value: name,
                              comparison: .contains,
                              options: [.localeSensitive]).predicate

    let expected = #"name CONTAINS[l] "\#(name)""#
    XCTAssertEqual(expected, predicate.description)
  }

  func test_DiacriticAndCaseInsensitiveOption_Name() {
    let name = data.femaleNames.randomElement()!.uppercased()[prefix: 2]

    let predicate = Predicate(key: #keyPath(Person.name),
                              value: name,
                              comparison: .contains,
                              options: [.caseInsensitive, .diacriticInsensitive]).predicate

    let expected = #"name CONTAINS[cd] "\#(name)""#
    XCTAssertEqual(expected, predicate.description)
  }
}
