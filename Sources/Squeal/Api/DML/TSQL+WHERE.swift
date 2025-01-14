//
//  SQL+WHERE.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

// TODO try return WHereClause?
public protocol WHEREClause: TableSQLQuery, ANDableQuery, LimitableQuery, GroupByableQuery {
    
}

public struct TypedWhereSQLQuery<T: Table>: WHEREClause {
    
    public let table: T
    public var query: String = ""
    public var parameters: [(any Encodable)?]
        
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}

public protocol WHEREableQuery: TableSQLQuery {
    func WHERE<U>(_ kp: KeyPath<T, Field<U>>, in values: [String]) -> TypedWhereSQLQuery<T>
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T>
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y?>) -> TypedWhereSQLQuery<T>
}


public extension WHEREableQuery {

    func WHERE<U>(_ kp: KeyPath<T, Field<U>>, in values: [String]) -> TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table, query: query + " WHERE" + " \(table[keyPath: kp].name)" + " in (\(values.map{"'\($0)'"}.joined(separator: ", ")))", parameters: []) //TODO fix
    }

    func WHERE<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T> {
        let q = query + " WHERE \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table,
                                  query: q,
                                  parameters: parameters + [predicate.right])
    }
    
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y?>) -> TypedWhereSQLQuery<T> {
        let q = query + " WHERE \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters:  parameters + [predicate.right!])
    }
}

