//
//  SQL+FROM.swift
//  
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public struct TypedFromSQLQuery<T: Table>: TableSQLQuery, JoinableQuery, WHEREableQuery, GroupByableQuery, OrderByableQuery, LimitableQuery {    
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
        
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}

public protocol FROMableQuery: TableSQLQuery {
    func FROM(_ table: T) -> TypedFromSQLQuery<T>
}

public extension FROMableQuery {
    
    func FROM(_ table: T) -> TypedFromSQLQuery<T> {
        if query.contains("FROM") {
            return TypedFromSQLQuery(for: table, query: query, parameters: [])
        }
        return TypedFromSQLQuery(for: table, query: query + " FROM \(T.schema)", parameters: [])
    }
}


public protocol FROMableSQLQuery: SQLQuery {
    func FROM<T>(_ table: T) -> TypedFromSQLQuery<T>
}


public extension FROMableSQLQuery {
    
    func FROM<T>(_ table: T) -> TypedFromSQLQuery<T> {
        if query.contains("FROM") {
            return TypedFromSQLQuery(for: table, query: query, parameters: [])
        }
        return TypedFromSQLQuery(for: table, query: query + " FROM \(T.schema)", parameters: [])
    }
}
