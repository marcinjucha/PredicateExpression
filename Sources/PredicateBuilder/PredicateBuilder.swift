import Foundation

public protocol PredicateProvider {
  var predicate: NSPredicate { get }
}

public protocol PredicateComposing: AnyObject, PredicateProvider {
  func predicate(key: String,
                 value: CVarArg,
                 comparison: PredicateOperation.Comparison,
                 aggregate: PredicateOperation.Aggregate,
                 options: [PredicateOperation.Option]) -> PredicateComposing
  func predicate(key: String,
                 value: CVarArg,
                 comparison: PredicateOperation.Comparison,
                 options: [PredicateOperation.Option]) -> PredicateComposing
  func predicate(key: String, value: CVarArg, comparison: PredicateOperation.Comparison) -> PredicateComposing
  func compoundPredicate(type: PredicateOperation.LogicalType, handler: (PredicateComposing) -> PredicateComposing) -> PredicateComposing
}

// MARK: Predicate Builder

public class PredicateBuilder: PredicateComposing {

  private let type: PredicateOperation.LogicalType
  private var predicates: [PredicateProvider] = []

  public var predicate: NSPredicate {
    CompoundPredicate(
      type: type,
      subpredicates: predicates
    ).predicate
  }

  public init(type: PredicateOperation.LogicalType = .and) {
    self.type = type
  }

  public func predicate(key: String,
                        value: CVarArg,
                        comparison: PredicateOperation.Comparison,
                        aggregate: PredicateOperation.Aggregate = .skip,
                        options: [PredicateOperation.Option] = []) -> PredicateComposing {
    predicates.append(Predicate(key: key, value: value, comparison: comparison, aggregate: aggregate, options: options))
    return self
  }

  public func predicate(key: String,
                        value: CVarArg,
                        comparison: PredicateOperation.Comparison,
                        options: [PredicateOperation.Option]) -> PredicateComposing {
    predicate(key: key, value: value, comparison: comparison, aggregate: .skip, options: options)
  }

  public func predicate(key: String,
                        value: CVarArg,
                        comparison: PredicateOperation.Comparison) -> PredicateComposing {
    predicate(key: key, value: value, comparison: comparison, aggregate: .skip, options: [])
  }

  public func compoundPredicate(type: PredicateOperation.LogicalType,
                                handler: (PredicateComposing) -> PredicateComposing) -> PredicateComposing {
    predicates.append(handler(PredicateBuilder(type: type)))
    return self
  }
}


// MARK: Predicate Operation

public enum PredicateOperation {
  public enum Aggregate: String {
    case skip = ""
    case any = "ANY"
    case all = "ALL"
    case notAny = "NOT ANY"
  }

  public enum Comparison: String {
    case equal = "=="
    case greaterEqual = ">="
    case greater = ">"
    case lessEqual = "<="
    case less = "<"
    case notEqual = "!="
    case between = "BETWEEN"
    case `in` = "IN"
    case beginsWith = "BEGINSWITH"
    case contains = "CONTAINS"
    case endsWith = "ENDSWITH"
    case like = "LIKE"
    case matches = "MATCHES"
  }

  public enum Option: String {
    case caseInsensitive = "c"
    case diacriticInsensitive = "d"
    case normalized = "n"
    case localeSensitive = "l"
  }

  public enum LogicalType {
    case and
    case or
    case not

    var type: NSCompoundPredicate.LogicalType {
      switch self {
      case .and: return .and
      case .or: return .or
      case .not: return .not
      }
    }
  }
}

// MARK: Predicate

struct Predicate: PredicateProvider {

  private let key: String
  private let value: CVarArg
  private var options: [PredicateOperation.Option]

  private let comparison: PredicateOperation.Comparison
  private let aggregate: PredicateOperation.Aggregate

  var predicate: NSPredicate {
    NSPredicate(format: "\(aggregate.rawValue) \(key) \(comparison.rawValue)\(options.predicateValue) \(value.predicateValue)")
  }

  init(key: String = "SELF",
       value: CVarArg,
       comparison: PredicateOperation.Comparison,
       aggregate: PredicateOperation.Aggregate = .skip,
       options: [PredicateOperation.Option] = []) {
    self.key = key
    self.value = value
    self.comparison = comparison
    self.aggregate = aggregate
    self.options = options
  }
}

private extension CVarArg {
  var predicateValue: CVarArg {
    switch self {
    case let value as String: return "'\(value)'"
    case let value as Array<CVarArg>: return value.predicateValue
    default: return self
    }
  }
}

private extension Array where Element == CVarArg {
  var predicateValue: CVarArg {
    "{ \(map { "\($0.predicateValue)" }.joined(separator: ", ")) }"
  }
}

private extension Array where Element == PredicateOperation.Option {
  var predicateValue: String {
    if isEmpty { return "" }

    return "[\(map { $0.rawValue }.joined())]"
  }
}

// MARK: Compound Predicate

struct CompoundPredicate: PredicateProvider {
  private let type: PredicateOperation.LogicalType
  private let subpredicates: [PredicateProvider]

  var predicate: NSPredicate {
    NSCompoundPredicate(type: type.type, subpredicates: subpredicates.map { $0.predicate })
  }

  init(type: PredicateOperation.LogicalType, subpredicates: [PredicateProvider]) {
    self.type = type
    self.subpredicates = subpredicates
  }
}

