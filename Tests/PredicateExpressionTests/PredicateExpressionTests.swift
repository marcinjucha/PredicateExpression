import XCTest
import Foundation
@testable import PredicateExpression

class PredicateExpressionTests: XCTestCase {

    private lazy var array = data.test
    private let data = PersonTestData()

    let nameKey = #keyPath(Person.name)
    let ageKey = #keyPath(Person.age)
    let partnerAgeKey = #keyPath(Person.partner.age)
    let partnerNameKey = #keyPath(Person.partner.name)
    let childrenAgeKey = #keyPath(Person.children.age)

    var femaleName: String { data.femaleNames.randomElement()! }
    var maleName: String { data.maleNames.randomElement()! }
    let age = 40
    let partnerAge = 60

    // MARK: Comparison

    func test_Equal_WithName() {
        let name = femaleName
        NSPredicate(nameKey == name)
            .verify(predicate: predicate(key: nameKey, value: name, comparison: .equal))
            .verify(data.test, filterHandler: { $0.name == name })
    }

    func test_GreaterEqual_AgeGreaterEqual40() {
        NSPredicate(ageKey >= age)
            .verify(predicate: predicate(key: ageKey, value: age, comparison: .greaterEqual))
            .verify(data.test, filterHandler: { $0.age >= age })
    }

    func test_GreaterEqual_AggregateAny_ChildrenAge() {
        let age = 13

        NSPredicate(.array(childrenAgeKey >= age, aggregate: .any))
            .verify(predicate: predicate(key: childrenAgeKey, value: age, comparison: .greaterEqual, aggregate: .any))
            .verify(data.test, filterHandler: { $0.children.filter { $0.age >= age }.count > 0 })

    }

    func test_Greater_AggregateAny_ChildrenAge() {
        NSPredicate(.array(childrenAgeKey > age, aggregate: .any))
            .verify(predicate: predicate(key: childrenAgeKey, value: age, comparison: .greater, aggregate: .any))
            .verify(data.test, filterHandler: { $0.children.filter { $0.age > age }.count > 0 })
    }

    func test_LessThan_AggregateAny_ChildrenAge() {
        let age = 7

        NSPredicate(.array(childrenAgeKey <= age, aggregate: .any))
            .verify(predicate: predicate(key: childrenAgeKey, value: age, comparison: .lessEqual, aggregate: .any))
            .verify(data.test, filterHandler: { $0.children.filter { $0.age <= age }.count > 0 })
    }

    func test_Less_AggregateAny_ChildrenAge() {
        let age = 7

        NSPredicate(.array(childrenAgeKey < age, aggregate: .any))
            .verify(predicate: predicate(key: childrenAgeKey, value: age, comparison: .less, aggregate: .any))
            .verify(data.test, filterHandler: { $0.children.filter { $0.age < age }.count > 0 })
    }

    func test_NotEqual_AggregateAll_ChildrenAge() {
        let age = 10

        NSPredicate(.array(childrenAgeKey != age, aggregate: .all))
            .verify(predicate: predicate(key: childrenAgeKey, value: age, comparison: .notEqual, aggregate: .all))
            .verify(data.test, filterHandler: { $0.children.filter { $0.age == age }.count == 0 })
    }

    func test_Between_AggregateAll_ChildrenAge() {
        let lower = 7
        let upper = 13

        NSPredicate(.between(childrenAgeKey, values: [lower, upper], aggregate: .all))
            .verify(predicate: predicate(key: childrenAgeKey, value: [lower, upper], comparison: .between, aggregate: .all))
            .verify(data.test,
                    filterHandler: { $0.children.filter { $0.age < lower || $0.age > upper }.count == 0 })

    }

    func test_In_AggregateAll_ChildrenAge() {
        let numbers = [7, 9, 10, 11, 13]

        NSPredicate(.in(childrenAgeKey, values: numbers, aggregate: .all))
            .verify(predicate: predicate(key: childrenAgeKey, value: numbers, comparison: .in, aggregate: .all))
            .verify(data.test,
                    filterHandler: { $0.children.filter { numbers.contains($0.age) == false }.count == 0 })
    }

    func test_In_AggregateNone_ChildrenAge() {
        let numbers = [10, 11, 13]

        NSPredicate(.in(childrenAgeKey, values: numbers, aggregate: .none))
            .verify(predicate: predicate(key: childrenAgeKey, value: numbers, comparison: .in, aggregate: .none))
            .verify(data.test,
                    filterHandler: { $0.children.filter { numbers.contains($0.age) }.count == 0 })
    }

    func test_Less_AggregateNotAny_ChildrenAge() {
        let age = 8

        NSPredicate(.array(childrenAgeKey < age, aggregate: .none))
            .verify(predicate: predicate(key: childrenAgeKey, value: age, comparison: .less, aggregate: .none))
            .verify(data.test,
                    filterHandler: { $0.children.filter { $0.age < age }.count == 0 })

    }

    func test_BeginsWith_Name() {
        let name = maleName
        let prefix = name[prefix: 2]

        NSPredicate(.beginsWith(nameKey, value: name))
            .verify(predicate: stringPredicate(key: nameKey, value: name, comparison: .beginsWith))
            .verify(data.test,
                    filterHandler: { $0.name.hasPrefix(prefix) })

    }

    func test_Contains_Name() {
        let namePart = "le"

        NSPredicate(.contains(nameKey, value: namePart))
            .verify(predicate: stringPredicate(key: nameKey, value: namePart, comparison: .contains))
            .verify(data.test,
                    filterHandler: { $0.name.contains(namePart) })

    }

    func test_EndsWith_Name() {
        let name = femaleName
        let suffix = name[suffix: 2]

        NSPredicate(.endsWith(nameKey, value: suffix))
            .verify(predicate: stringPredicate(key: nameKey, value: suffix, comparison: .endsWith))
            .verify(data.test,
                    filterHandler: { $0.name.hasSuffix(suffix) })

    }

    func test_Like_Name() {
        let char = ["a", "i", "e", "l"].randomElement()!
        let name = "*\(char)?"

        NSPredicate(.like(nameKey, value: name))
            .verify(predicate: stringPredicate(key: nameKey, value: name, comparison: .like))
            .verify(data.test,
                    filterHandler: { $0.name[value: $0.name.count - 2] == char })

    }

    func test_Matches_Name() {
        let regex = ".*ll?.*"
        NSPredicate(.regex(nameKey, value: regex))
            .verify(predicate: stringPredicate(key: nameKey, value: regex, comparison: .matches))
            .verify(data.test,
                    filterHandler: { $0.name.range(of: regex, options: .regularExpression) != nil })

    }

    func test_String_Options_Name() {
        let name = data.femaleNames.randomElement()!.uppercased()[prefix: 2]

        [Option.caseInsensitive, .diacriticInsensitive, .normalized, .localeSensitive]
            .forEach { option in
            let predicate = NSPredicate(.contains(nameKey, value: name, options: option))

            let expected = #"name CONTAINS[\#(option.rawValue)] "\#(name)""#
            XCTAssertEqual(expected, predicate.description)
        }
    }

    func test_DiacriticAndCaseInsensitiveOption_Name() {
        let name = data.femaleNames.randomElement()!.uppercased()[prefix: 2]

        let predicate = NSPredicate(.contains(nameKey, value: name, options: .diacriticInsensitive, .caseInsensitive))


        let expected = #"name CONTAINS[cd] "\#(name)""#
        XCTAssertEqual(expected, predicate.description)
    }


    // MARK: Logical compound predicates
    func test_And_EqualWithName_GreaterWithAge() {
        let name = femaleName
        NSPredicate(nameKey == name && ageKey > age)
            .verify(predicate: compoundPredicate(type: .and, subpredicates: [
                NSPredicate(nameKey == name), NSPredicate(ageKey > age)
            ]))
            .verify(data.test, filterHandler: { $0.name == name && $0.age > age })
    }

    func test_Not_EqualWithName() {
        let name = femaleName
        NSPredicate(!(nameKey == name))
            .verify(predicate: compoundPredicate(type: .not, subpredicates: [
                NSPredicate(nameKey == name)
            ]))
            .verify(data.test, filterHandler: { $0.name != name })
    }

    func test_Not_EqualWithName_GreaterAge() {
        let name = femaleName
        NSPredicate(!(nameKey == name && ageKey > age))
            .verify(predicate: compoundPredicate(type: .not, subpredicates: [
                compoundPredicate(type: .and, subpredicates: [
                    NSPredicate(nameKey == name), NSPredicate(ageKey > age)
                ])
            ]))
            .verify(data.test, filterHandler: { !($0.name == name && $0.age > age) })
    }

    func test_Or_EqualWithName_LessWithAge() {
        let age = 50
        let name = femaleName

        NSPredicate(nameKey == name || ageKey < age)
            .verify(predicate: compoundPredicate(type: .or, subpredicates: [
                NSPredicate(nameKey == name), NSPredicate(ageKey < age)
            ]))
            .verify(data.test, filterHandler: { $0.name == name || $0.age < age })
    }


    func test_And_EqualWithName_Or_GreaterWithAge_LessPartnerWithAge() {
        let name = femaleName

        NSPredicate(nameKey == name && (ageKey > age || partnerAgeKey < age))
            .verify(predicate: compoundPredicate(type: .and, subpredicates: [
                NSPredicate(nameKey == name),
                compoundPredicate(type: .or, subpredicates: [.init(ageKey > age), .init(partnerAgeKey < age)])
            ]))
            .verify(data.test, filterHandler: { $0.name == name && ($0.age > age || $0.partner.age < age) })
    }

    func test_Or_EqualWithName_And_GreaterWithAge_PartnerWithName_LessPartnerAgeWithPartnerAge() {
        let name = femaleName
        let parentName = maleName

        NSPredicate(nameKey == name || (ageKey > age && partnerNameKey == parentName && partnerAgeKey < partnerAge))
            .verify(predicate: compoundPredicate(type: .or, subpredicates: [
                NSPredicate(nameKey == name),
                compoundPredicate(type: .and, subpredicates: [
                    .init(ageKey > age), .init(partnerNameKey == parentName), .init(partnerAgeKey < partnerAge)
                ])
            ]))
            .verify(data.test, filterHandler: {
                $0.name == name || ($0.age > age && $0.partner.name == parentName && $0.partner.age < partnerAge)
            })
    }

    private func predicate(key: String, value: CVarArg, comparison: Comparison, aggregate: Aggregate = .skip) -> NSPredicate {
        NSPredicate(format: "\(aggregate.rawValue) \(key) \(comparison.rawValue) \(value.predicateValue)")
    }

    private func stringPredicate(key: String, value: CVarArg, comparison: Comparison, options: [Option] = []) -> NSPredicate {
        NSPredicate(format: "\(key) \(comparison.rawValue)\(options.value) \(value.predicateValue)")
    }

    private func compoundPredicate(type: NSCompoundPredicate.LogicalType, subpredicates: [NSPredicate]) -> NSPredicate {
        NSCompoundPredicate(type: type, subpredicates: subpredicates)
    }
}
