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
}
