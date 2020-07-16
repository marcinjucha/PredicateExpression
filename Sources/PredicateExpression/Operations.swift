
import Foundation

public enum Aggregate: String {
    case skip = ""
    /// returns objects where ANY of the predicate results are true.
    case any = "ANY"
    // returns objects where ALL of the predicate results are true.
    case all = "ALL"
    /// returns objects where NONE of the predicate results are true.
    case none = "NONE"
}

public enum Option: String {
    /// A case-insensitive predicate.
    /// for example, "NeXT" like[c] "next".
    case caseInsensitive = "c"
    /// A diacritic-insensitive predicate.
    /// for example, "naïve" like[d] "naive".
    case diacriticInsensitive = "d"
    /// Indicates that the strings to be compared have been preprocessed.
    /// This option supersedes CaseInsensitive and DiacriticInsensitive, and is intended as a performance optimization option.
    case normalized = "n"
    /// Indicates that strings to be compared using <, <=, =, =>, > should be handled in a locale-aware fashion.
    /// for example, "straße" >[l] "strasse"
    case localeSensitive = "l"
}

enum Comparison: String {
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

enum LogicalType: String {
    case and = "AND"
    case or = "OR"
    case not = "NOT"
}

enum Expression {
    case key(String)
    case value(CVarArg)
    indirect case expression(Comparison, Expression, Expression)
    indirect case array(Expression, aggregate: Aggregate = .skip)
    indirect case string(Expression, options: [Option] = [])
    indirect case logical(LogicalType, [Expression])

    var predicate: String {
        switch self {
        case .key(let value):
            return value
        case .value(let value):
            return "\(value.predicateValue)"
        case .expression:
            return combine()
        case let .array(expression, aggregate):
            return expression.combine(aggregate: aggregate)
        case let .string(expression, options):
            return expression.combine(options: options)
        case let .logical(logicalType, expressions) where logicalType == .not:
            return "( \(logicalType.rawValue) \(expressions.joined(using: " ")) )"
        case let .logical(logicalType, expressions):
            return "( \(expressions.joined(using: " \(logicalType.rawValue) ")) )"
        }
    }

    private func combine(aggregate: Aggregate = .skip, options: [Option] = []) -> String {
        guard case let .expression(comparison, lhs, rhs) = self else { return predicate }

        return "(\(aggregate.rawValue) \(lhs.predicate) \(comparison.rawValue)\(options.value) \(rhs.predicate) )"
    }
}

extension CVarArg {
    var predicateValue: CVarArg {
        switch self {
        case let value as String: return "'\(value)'"
        case let value as Array<CVarArg>: return value.predicateValue
        default: return self
        }
    }
}

extension Array where Element == CVarArg {
    var predicateValue: CVarArg {
        "{ \(map { "\($0.predicateValue)" }.joined(separator: ", ")) }"
    }
}

extension Array where Element == Expression {
    func joined(using separator: String) -> String {
        map { $0.predicate }.joined(separator: separator)
    }
}

extension Array where Element == Option {
    var value: String {
        if isEmpty { return "" }

        return "[\(map { $0.rawValue }.joined())]"
    }
}
