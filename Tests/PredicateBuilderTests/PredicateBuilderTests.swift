import XCTest
@testable import PredicateBuilder

class PredicateBuilderComparableTests: XCTestCase {
  lazy var sut = PredicateBuilder()
  private lazy var array = data.test
  private let data = PersonTestData()

  func test_ComparisonEqual_WithName() {
    let name = data.femaleNames.randomElement()!

    sut
      .predicate(key: #keyPath(Person.name), value: name, comparison: .equal)
      .predicate
      .verify(data.test, filterHandler: { $0.name == name })
  }

  func test_ComposableAnd_EqualWithName_GreaterWithAge() {
    let name = data.femaleNames.randomElement()!
    let age = 40

    sut
      .compoundPredicate(type: .and,
                         handler: { builder in
                          builder
                            .predicate(key: #keyPath(Person.name), value: name, comparison: .equal)
                            .predicate(key: #keyPath(Person.age), value: age, comparison: .greater)
      })
      .predicate
      .verify(data.test, filterHandler: { $0.name == name && $0.age > age })
  }

  func test_ComposableOr_EqualWithName_GreaterWithAge() {
    let name = data.femaleNames.randomElement()!
    let age = 40

    sut
      .compoundPredicate(type: .or,
                         handler: { builder in
                          builder
                            .predicate(key: #keyPath(Person.name), value: name, comparison: .equal)
                            .predicate(key: #keyPath(Person.age), value: age, comparison: .greater)
      })
      .predicate
      .verify(data.test, filterHandler: { $0.name == name || $0.age > age })
  }

  func test_ComposableAnd_EqualWithName_ComposableOr_GreaterWithAge_LessPartnerWithAge() {
    let name = data.femaleNames.randomElement()!
    let age = 40

    sut
      .compoundPredicate(type: .and,
                         handler: { builder in
                          builder
                            .predicate(key: #keyPath(Person.name), value: name, comparison: .equal)
                            .compoundPredicate(type: .or) { builder in
                              builder
                                .predicate(key: #keyPath(Person.age), value: age, comparison: .greater)
                                .predicate(key: #keyPath(Person.partner.age), value: age, comparison: .less)
                          }
      })
      .predicate
      .verify(data.test, filterHandler: { $0.name == name && ($0.age > age || $0.partner.age < age) })
  }

  func test_ComposableOr_EqualWithName_ComposableAnd_GreaterWithAge_PartnerWithName_LessPartnerAgeWithPartnerAge() {
    let name = data.femaleNames.randomElement()!
    let partnerName = data.maleNames.randomElement()!
    let age = 40
    let partnerAge = 60

    sut
      .compoundPredicate(type: .or,
                         handler: { builder in
                          builder
                            .predicate(key: #keyPath(Person.name), value: name, comparison: .equal)
                            .compoundPredicate(type: .and) { builder in
                              builder
                                .predicate(key: #keyPath(Person.age), value: age, comparison: .greater)
                                .predicate(key: #keyPath(Person.partner.name), value: partnerName, comparison: .equal)
                                .predicate(key: #keyPath(Person.partner.age), value: partnerAge, comparison: .less)
                          }
      })
      .predicate
      .verify(data.test, filterHandler: {
        $0.name == name || ($0.age > age && $0.partner.name == partnerName && $0.partner.age < partnerAge)
      })
  }
}
