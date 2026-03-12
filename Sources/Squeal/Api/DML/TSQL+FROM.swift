//
//  SQL+FROM.swift
//  
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public struct TypedFromSQLQuery<T: Table, Row>: TableSQLQuery, JoinableQuery, WHEREableQuery, GroupByableQuery, OrderByableQuery, LimitableQuery, OffsetableQuery {
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
    func FROM(_ table: T) -> TypedFromSQLQuery<T, Row>
}

public extension FROMableQuery {
    
    func FROM(_ table: T) -> TypedFromSQLQuery<T, Row> {
        return TypedFromSQLQuery(for: table, query: query + " FROM \(T.schema)", parameters: [])
    }
}


public protocol FROMableSQLQuery: SQLQuery {
    func FROM<T>(_ table: T) -> TypedFromSQLQuery<T, Void>
}


public extension FROMableSQLQuery {
    
    func FROM<T>(_ table: T) -> TypedFromSQLQuery<T, Void> {
        return TypedFromSQLQuery(for: table, query: query + " FROM \(T.schema)", parameters: [])
    }
}
