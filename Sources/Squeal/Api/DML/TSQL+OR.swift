//
//  TSQL+AND.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

/// A query after an `OR` condition.
public protocol ORClause: WHEREClause {
    
}


/// A query that can be followed by an `OR` condition.
public protocol ORableQuery: TableSQLQuery {
    /// Adds an alternative comparison: `OR column <op> $n`.
    ///
    /// Conditions aren't parenthesized, so `AND` binds tighter than `OR`.
    func OR<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T, Row>
    /// Adds an alternative condition that the column is in a list of values: `OR column IN ($1, …)`.
    func OR<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, IN values: [U]) -> TypedWhereSQLQuery<T, Row>
    /// Adds an alternative condition that the column matches a pattern: `OR column LIKE $n`.
    func OR<U>(_ kp: KeyPath<T, TableColumn<T,U>>, LIKE value: String) -> TypedWhereSQLQuery<T, Row>
}

public extension ORableQuery {
    
    /// Adds an alternative comparison: `OR column <op> $n`.
    ///
    /// Conditions aren't parenthesized, so `AND` binds tighter than `OR`.
    func OR<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T, Row> {
        let q = query + " OR \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }

    /// Adds an alternative condition that the column is in a list of values: `OR column IN ($1, …)`.
    func OR<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, IN values: [U]) -> TypedWhereSQLQuery<T, Row> {
        var pNumber = parameterNumber()
        func nextParamSign() -> String {
            pNumber += 1
            return "$\(pNumber)"
        }
        return TypedWhereSQLQuery(for: table, query: query + " OR \(table[keyPath: kp].name) IN (\(values.map{_ in "\(nextParamSign())"}.joined(separator: ", ")))", parameters: parameters + values)
    }

    /// Adds an alternative condition that the column matches a pattern: `OR column LIKE $n`.
    func OR<U>(_ kp: KeyPath<T, TableColumn<T,U>>, LIKE value: String) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " OR \(table[keyPath: kp].name) LIKE \(nextDollarSign())", parameters: parameters + [value])
    }

    /// Adds an alternative condition written as a SQL expression whose `?` placeholders are
    /// bound as parameters.
    ///
    /// ```swift
    /// .WHERE(\.name == "admin")
    /// .OR(SQLExpr("(age >= ? AND bio IS NOT NULL)", 18))
    /// // WHERE name = $1 OR (age >= $2 AND bio IS NOT NULL)
    /// ```
    func OR(_ expression: SQLExpr) -> TypedWhereSQLQuery<T, Row> {
        let (fragments, newParameters) = renderSQLValues([expression], parameterOffset: parameterNumber())
        return TypedWhereSQLQuery(for: table, query: query + " OR \(fragments[0])", parameters: parameters + newParameters)
    }

    /// Adds an alternative comparison of two table-qualified columns: `OR a.x = b.y`.
    func OR<A: Table, B: Table, F>(_ predicate: JOINPredicate<A, B, F>) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " OR \(predicate.sql)", parameters: parameters)
    }

    /// Adds an alternative condition that a subquery returns any row: `OR EXISTS (SELECT …)`.
    func OR(_ condition: EXISTS) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " OR \(condition.sql(after: self))", parameters: parameters + condition.subquery.parameters)
    }

    /// Adds an alternative condition that a subquery returns no row: `OR NOT EXISTS (SELECT …)`.
    func OR(_ condition: NOT_EXISTS) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " OR \(condition.sql(after: self))", parameters: parameters + condition.subquery.parameters)
    }
}
