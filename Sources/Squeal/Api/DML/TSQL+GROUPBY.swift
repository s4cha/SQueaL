//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public struct TypedGroupBySQLQuery<T: Table>: TableSQLQuery, LimitableQuery {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
    
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}

public protocol GroupByableQuery: TableSQLQuery {

    func GROUP_BY(_ value: String) -> TypedGroupBySQLQuery<T>
}

public extension GroupByableQuery {
    
    func GROUP_BY(_ value: String) -> TypedGroupBySQLQuery<T> {
        return TypedGroupBySQLQuery(for: table, query: query + " " + "GROUP BY \(value)", parameters: parameters)
    }
}

