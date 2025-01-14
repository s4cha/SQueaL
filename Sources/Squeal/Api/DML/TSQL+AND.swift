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
    func AND<U: Encodable>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> TypedWhereSQLQuery<T>
    func AND<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T>
}

public extension ANDableQuery {

    func AND<U: Encodable>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> TypedWhereSQLQuery<T> {
        let q = query + " " + "AND" + " \(table[keyPath: kp].name)" + " = " + "\(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [value])
    }
    
    func AND<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T> {
        let q = query + " AND \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }
}
