//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public struct TypedHavingSQLQuery<T: Table>: TableSQLQuery, LimitableQuery {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
    
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}

public protocol HavingableQuery: TableSQLQuery {
    func HAVING(_ clause: String) -> TypedHavingSQLQuery<T>
}

public extension HavingableQuery {
    
    func HAVING(_ clause: String) -> TypedHavingSQLQuery<T> {
        return TypedHavingSQLQuery(for: table, query: query + " HAVING \(clause)", parameters: parameters)
    }
}

