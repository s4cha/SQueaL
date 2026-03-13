//
//  TSQL+AND.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public protocol ORClause: WHEREClause {
    
}


public protocol ORableQuery: TableSQLQuery {
    func OR<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T, Row>
    func OR<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, IN values: [U]) -> TypedWhereSQLQuery<T, Row>
    func OR<U>(_ kp: KeyPath<T, TableColumn<T,U>>, LIKE value: String) -> TypedWhereSQLQuery<T, Row>
}

public extension ORableQuery {
    
    func OR<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T, Row> {
        let q = query + " OR \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }

    func OR<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, IN values: [U]) -> TypedWhereSQLQuery<T, Row> {
        var pNumber = parameterNumber()
        func nextParamSign() -> String {
            pNumber += 1
            return "$\(pNumber)"
        }
        return TypedWhereSQLQuery(for: table, query: query + " OR \(table[keyPath: kp].name) IN (\(values.map{_ in "\(nextParamSign())"}.joined(separator: ", ")))", parameters: parameters + values)
    }

    func OR<U>(_ kp: KeyPath<T, TableColumn<T,U>>, LIKE value: String) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " OR \(table[keyPath: kp].name) LIKE \(nextDollarSign())", parameters: parameters + [value])
    }
}
