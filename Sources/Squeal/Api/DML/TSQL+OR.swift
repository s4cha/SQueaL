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
    func AND<U: Encodable>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> TypedWhereSQLQuery<T>
    func AND<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T>
}

public extension ORableQuery {

    func OR<U: Encodable>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> TypedWhereSQLQuery<T> {
        let q = query + " " + "OR" + " \(table[keyPath: kp].name)" + " = " + "\(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [value])
    }
    
    func OR<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T> {
        let q = query + " OR \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }
}
