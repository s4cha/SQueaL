//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public struct TypedLimitSQLQuery<T: Table>: SQLQuery {
    
    let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
    
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}

public extension TypedFromSQLQuery {
    
    func LIMIT(_ value: Int) -> TypedLimitSQLQuery<T> {
        return TypedLimitSQLQuery(for: table, query: query + " " + "LIMIT \(value)", parameters: parameters)
    }
}

public extension TypedWhereSQLQuery {
    
    func LIMIT(_ value: Int) -> TypedLimitSQLQuery<T> {
        return TypedLimitSQLQuery(for: table, query: query + " " + "LIMIT \(value)", parameters: parameters)
    }
}
