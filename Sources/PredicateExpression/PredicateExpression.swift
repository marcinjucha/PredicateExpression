
import Foundation

public extension NSPredicate {
    convenience init(_ expression: PredicateExpression) {
        self.init(format: expression.expression.predicate)
    }
}

public struct PredicateExpression {
    let expression: Expression

    init(_ expression: Expression) {
        self.expression = expression
    }
}

// MARK: Array

public extension PredicateExpression {
    static func array(_ expression: PredicateExpression, aggregate: Aggregate) -> PredicateExpression {
        .init(.array(expression.expression, aggregate: aggregate))
    }

    static func between(_ key: String, values: CVarArg, aggregate: Aggregate) -> PredicateExpression {
        assert(values is Array<CVarArg>, "Invalid values - \(values) should be an array.")

        return expression(key, values: values, comparison: .between, aggregate: aggregate)
    }

    static func `in`(_ key: String, values: CVarArg, aggregate: Aggregate) -> PredicateExpression {
        assert(values is Array<CVarArg>, "Invalid values - \(values) should be an array.")

        return expression(key, values: values, comparison: .in, aggregate: aggregate)
    }

    private static func expression(_ key: String, values: CVarArg, comparison: Comparison, aggregate: Aggregate) -> PredicateExpression {
        .init(.array(.expression(comparison, .key(key), .value(values)), aggregate: aggregate))
    }
}

// MARK: Strings

public extension PredicateExpression {
    static func beginsWith(_ key: String, value: CVarArg, options: Option...) -> PredicateExpression {
        expression(key, value: value, comparison: .beginsWith, options: options)
    }

    static func contains(_ key: String, value: CVarArg, options: Option...) -> PredicateExpression {
        expression(key, value: value, comparison: .contains, options: options)
    }

    static func endsWith(_ key: String, value: CVarArg, options: Option...) -> PredicateExpression {
        expression(key, value: value, comparison: .endsWith, options: options)
    }

    static func like(_ key: String, value: CVarArg, options: Option...) -> PredicateExpression {
        expression(key, value: value, comparison: .like, options: options)
    }

    static func regex(_ key: String, value: CVarArg, options: Option...) -> PredicateExpression {
        expression(key, value: value, comparison: .matches, options: options)
    }

    private static func expression(_ key: String, value: CVarArg, comparison: Comparison, options: [Option]) -> PredicateExpression {
        .init(.string(.expression(comparison, .key(key), .value(value)), options: options))
    }
}

public func ==(key: String, value: CVarArg) -> PredicateExpression {
    .init(.expression(.equal, .key(key), .value(value)))
}

public func !=(key: String, value: CVarArg) -> PredicateExpression {
    .init(.expression(.notEqual, .key(key), .value(value)))
}

public func >(key: String, value: CVarArg) -> PredicateExpression {
    .init(.expression(.greater, .key(key), .value(value)))
}

public func >=(key: String, value: CVarArg) -> PredicateExpression {
    .init(.expression(.greaterEqual, .key(key), .value(value)))
}

public func <(key: String, value: CVarArg) -> PredicateExpression {
    .init(.expression(.less, .key(key), .value(value)))
}

public func <=(key: String, value: CVarArg) -> PredicateExpression {
    .init(.expression(.lessEqual, .key(key), .value(value)))
}

public func &&(lhs: PredicateExpression, rhs: PredicateExpression) -> PredicateExpression {
    .init(.logical(.and, [lhs.expression, rhs.expression]))
}

public func ||(lhs: PredicateExpression, rhs: PredicateExpression) -> PredicateExpression {
    .init(.logical(.or, [lhs.expression, rhs.expression]))
}

public prefix func !(expr: PredicateExpression) -> PredicateExpression {
    .init(.logical(.not, [expr.expression]))
}

