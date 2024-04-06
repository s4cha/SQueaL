//
//  SQL+FROM.swift
//  
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public struct TypedFromSQLQuery<T: Table>: SQLQuery {
    let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
        
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}

public extension TypedSelectSQLQuery {
    
    func FROM(_ tableName: String) -> TypedFromSQLQuery<T> {
        let q = query + " FROM \(tableName)"
        return TypedFromSQLQuery(for: table, query: q, parameters: [])
    }
    
    func FROM(_ table: T) -> TypedFromSQLQuery<T> {
        if query.contains("FROM") {
            return TypedFromSQLQuery(for: table, query: query, parameters: [])
        }
        return TypedFromSQLQuery(for: table, query: query + " FROM \(table.tableName)", parameters: [])
    }
}
