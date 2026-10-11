//
//  SQL+OFFSET.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

/// A query after its `OFFSET` clause. It accepts no further clauses.
public struct TypedOffsetSQLQuery<T: Table, Row>: TableSQLQuery {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
    
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}


/// A query that can be followed by an `OFFSET` clause.
public protocol OffsetableQuery: TableSQLQuery {

    /// Skips the first `value` rows: `OFFSET value`.
    ///
    /// ```swift
    /// .ORDER_BY(\.id).LIMIT(20).OFFSET(40)   // the third page of 20
    /// ```
    func OFFSET(_ value: Int) -> TypedOffsetSQLQuery<T, Row>
}

public extension OffsetableQuery {
    
    /// Skips the first `value` rows: `OFFSET value`.
    ///
    /// ```swift
    /// .ORDER_BY(\.id).LIMIT(20).OFFSET(40)   // the third page of 20
    /// ```
    func OFFSET(_ value: Int) -> TypedOffsetSQLQuery<T, Row> {
        return TypedOffsetSQLQuery(for: table, query: query + " " + "OFFSET \(value)", parameters: parameters)
    }
}


