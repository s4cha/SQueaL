//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

/// A query after its `LIMIT` clause. Next, you can add `OFFSET`.
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


/// A query that can be followed by a `LIMIT` clause.
public protocol LimitableQuery: TableSQLQuery {

    /// Returns at most `value` rows: `LIMIT $n`, with `value` bound as a parameter.
    func LIMIT(_ value: Int) -> TypedLimitSQLQuery<T, Row>
}

public extension LimitableQuery {
    
    /// Returns at most `value` rows: `LIMIT $n`, with `value` bound as a parameter.
    func LIMIT(_ value: Int) -> TypedLimitSQLQuery<T, Row> {
        return TypedLimitSQLQuery(for: table, query: query + " LIMIT \(nextDollarSign())", parameters: parameters + [value])
    }
}


