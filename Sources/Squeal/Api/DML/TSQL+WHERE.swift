//
//  SQL+WHERE.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

// TODO try return WHereClause?
public protocol WHEREClause: TableSQLQuery, ANDableQuery, ORableQuery, LimitableQuery, GroupByableQuery, OrderByableQuery {
    
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

public struct PartialTypedWhereSQLQuery<T: Table, U>: TableSQLQuery {
    
    public let table: T
    public var query: String = ""
    public var parameters: [(any Encodable)?]
    public let keypath: KeyPath<T, Field<U>>
        
    init(for table: T, query: String, parameters: [(any Encodable)?], keypath: KeyPath<T, Field<U>>) {
        self.table = table
        self.query = query
        self.parameters = parameters
        self.keypath = keypath
    }
}

extension PartialTypedWhereSQLQuery {
    var IS_NULL: TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table,
                                  query: query + " WHERE \(table[keyPath: keypath].name) IS NULL",
                                  parameters: parameters)
    }
    
    var IS_NOT_NULL: TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table,
                                  query: query + " WHERE \(table[keyPath: keypath].name) IS NOT NULL",
                                  parameters: parameters)
    }
}

public protocol WHEREableQuery: TableSQLQuery {
    func WHERE<U>(_ kp: KeyPath<T, Field<U>>, IN values: [String]) -> TypedWhereSQLQuery<T>
    func WHERE<U>(_ kp: KeyPath<T, Field<U>>, LIKE value: String) -> TypedWhereSQLQuery<T>
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T>
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y?>) -> TypedWhereSQLQuery<T>
    
    func WHERE<U>(_ kp: KeyPath<T, Field<U>>) -> PartialTypedWhereSQLQuery<T, U>
}


public extension WHEREableQuery {

    func WHERE<U>(_ kp: KeyPath<T, Field<U>>, IN values: [String]) -> TypedWhereSQLQuery<T> {
        
        var pNumber = parameterNumber()
        func nextParamSign() -> String {
            pNumber += 1
            return "$\(pNumber)"
        }
        
        return TypedWhereSQLQuery(for: table, query: query + " WHERE" + " \(table[keyPath: kp].name)" + " IN (\(values.map{_ in "\(nextParamSign())"}.joined(separator: ", ")))", parameters: parameters + values) //TODO fix
    }
    
    func WHERE<U>(_ kp: KeyPath<T, Field<U>>, LIKE value: String) -> TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(table[keyPath: kp].name) like \(nextDollarSign())", parameters: parameters + [value])
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
    
    func WHERE<U>(_ kp: KeyPath<T, Field<U>>) -> PartialTypedWhereSQLQuery<T, U> {
        return PartialTypedWhereSQLQuery(for: table, query: query, parameters: parameters, keypath: kp)
    }
}

