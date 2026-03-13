//
//  TSQL+AND.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public protocol ANDClause: WHEREClause {
    
}


public protocol ANDableQuery: TableSQLQuery {
    func AND<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T, Row>
    func AND<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, IN values: [U]) -> TypedWhereSQLQuery<T, Row>
    func AND<U>(_ kp: KeyPath<T, TableColumn<T,U>>, LIKE value: String) -> TypedWhereSQLQuery<T, Row>
}

public extension ANDableQuery {
    
    func AND<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T, Row> {
        let q = query + " AND \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }

    func AND<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, IN values: [U]) -> TypedWhereSQLQuery<T, Row> {
        var pNumber = parameterNumber()
        func nextParamSign() -> String {
            pNumber += 1
            return "$\(pNumber)"
        }
        return TypedWhereSQLQuery(for: table, query: query + " AND \(table[keyPath: kp].name) IN (\(values.map{_ in "\(nextParamSign())"}.joined(separator: ", ")))", parameters: parameters + values)
    }

    func AND<U>(_ kp: KeyPath<T, TableColumn<T,U>>, LIKE value: String) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " AND \(table[keyPath: kp].name) LIKE \(nextDollarSign())", parameters: parameters + [value])
    }
}
