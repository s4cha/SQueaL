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
    func AND<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T>
}

public extension ANDableQuery {
    
    func AND<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T> {
        let q = query + " AND \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }

}
