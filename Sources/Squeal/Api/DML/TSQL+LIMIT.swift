//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public struct TypedLimitSQLQuery<T: Table, Row>: TableSQLQuery, OffsetableQuery {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
    
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}


public protocol LimitableQuery: TableSQLQuery {

    func LIMIT(_ value: Int) -> TypedLimitSQLQuery<T, Row>
}

public extension LimitableQuery {
    
    func LIMIT(_ value: Int) -> TypedLimitSQLQuery<T, Row> {
        return TypedLimitSQLQuery(for: table, query: query + " " + "LIMIT \(value)", parameters: parameters)
    }
}


