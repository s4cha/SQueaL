//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


/// A query after its `HAVING` clause. Next, you can add `ORDER_BY`, `LIMIT` or `OFFSET`.
public struct TypedHavingSQLQuery<T: Table, Row>: TableSQLQuery, LimitableQuery, OffsetableQuery, OrderByableQuery {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
    
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}

/// A query that can be followed by a `HAVING` clause.
public protocol HavingableQuery: TableSQLQuery {
    /// Filters groups with a condition written as SQL: `HAVING clause`.
    ///
    /// ```swift
    /// .GROUP_BY(\.author_id).HAVING("COUNT(*) > 5")
    /// ```
    ///
    /// > Warning: The clause is inserted verbatim and isn't parameterized. Never build it from user input.
    func HAVING(_ clause: String) -> TypedHavingSQLQuery<T, Row>
}

public extension HavingableQuery {
    
    /// Filters groups with a condition written as SQL: `HAVING clause`.
    ///
    /// ```swift
    /// .GROUP_BY(\.author_id).HAVING("COUNT(*) > 5")
    /// ```
    ///
    /// > Warning: The clause is inserted verbatim and isn't parameterized. Never build it from user input.
    func HAVING(_ clause: String) -> TypedHavingSQLQuery<T, Row> {
        return TypedHavingSQLQuery(for: table, query: query + " HAVING \(clause)", parameters: parameters)
    }
}

