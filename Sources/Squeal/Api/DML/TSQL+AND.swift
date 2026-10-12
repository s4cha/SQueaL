//
//  TSQL+AND.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

/// A query after an `AND` condition.
public protocol ANDClause: WHEREClause {
    
}


/// A query that can be followed by an `AND` condition.
public protocol ANDableQuery: TableSQLQuery {
    /// Adds a comparison on a column of the main table: `AND column <op> $n`.
    ///
    /// ```swift
    /// .WHERE(\.age >= 18).AND(\.name == "Ada")
    /// ```
    func AND<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T, Row>
    /// Adds a condition that the column is in a list of values: `AND column IN ($1, …)`.
    func AND<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, IN values: [U]) -> TypedWhereSQLQuery<T, Row>
    /// Adds a condition that the column matches a pattern: `AND column LIKE $n`.
    func AND<U>(_ kp: KeyPath<T, TableColumn<T,U>>, LIKE value: String) -> TypedWhereSQLQuery<T, Row>
}

public extension ANDableQuery {
    
    /// Adds a comparison on a column of the main table: `AND column <op> $n`.
    ///
    /// ```swift
    /// .WHERE(\.age >= 18).AND(\.name == "Ada")
    /// ```
    func AND<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T, Row> {
        let q = query + " AND \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }

    /// Adds a condition that the column is in a list of values: `AND column IN ($1, …)`.
    func AND<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, IN values: [U]) -> TypedWhereSQLQuery<T, Row> {
        var pNumber = parameterNumber()
        func nextParamSign() -> String {
            pNumber += 1
            return "$\(pNumber)"
        }
        return TypedWhereSQLQuery(for: table, query: query + " AND \(table[keyPath: kp].name) IN (\(values.map{_ in "\(nextParamSign())"}.joined(separator: ", ")))", parameters: parameters + values)
    }

    /// Adds a condition that the column is among a subquery's results: `AND column IN (SELECT …)`.
    ///
    /// The subquery must select a single column of the same type. Its placeholders are renumbered to follow this query's placeholders.
    func AND<U, Q: TableSQLQuery>(_ kp: KeyPath<T, TableColumn<T, U>>, IN subquery: Q) -> TypedWhereSQLQuery<T, Row> where Q.Row == U {
        return TypedWhereSQLQuery(for: table, query: query + " AND \(table[keyPath: kp].name) IN (\(embedded(subquery)))", parameters: parameters + subquery.parameters)
    }

    /// Adds a condition that the nullable column is among a subquery's results: `AND column IN (SELECT …)`.
    func AND<U, Q: TableSQLQuery>(_ kp: KeyPath<T, TableColumn<T, U?>>, IN subquery: Q) -> TypedWhereSQLQuery<T, Row> where Q.Row == U {
        return TypedWhereSQLQuery(for: table, query: query + " AND \(table[keyPath: kp].name) IN (\(embedded(subquery)))", parameters: parameters + subquery.parameters)
    }

    /// AND on a column of any table (e.g. a JOINed one), qualified as `table.column`.
    func AND<U: Table, Y: Encodable>(_ predicate: TableColumnPredicate<U, Y>) -> TypedWhereSQLQuery<T, Row> {
        let q = query + " AND \(predicate.column.toString()) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }
    
    /// Adds a condition that the column matches a pattern: `AND column LIKE $n`.
    func AND<U>(_ kp: KeyPath<T, TableColumn<T,U>>, LIKE value: String) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " AND \(table[keyPath: kp].name) LIKE \(nextDollarSign())", parameters: parameters + [value])
    }
}
