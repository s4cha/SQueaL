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
    func OR<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T>
}

public extension ORableQuery {
    
    func OR<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T> {
        let q = query + " OR \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }
}
