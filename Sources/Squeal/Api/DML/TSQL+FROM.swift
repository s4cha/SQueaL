//
//  SQL+FROM.swift
//  
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


/// A query after its `FROM` clause, or after a `JOIN`.
///
/// Next, you can add `JOIN`, `WHERE`, `GROUP_BY`, `ORDER_BY`, `LIMIT` or `OFFSET`.
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

/// A query that can be followed by `FROM` with its own table type.
public protocol FROMableQuery: TableSQLQuery {
    /// Adds the `FROM` clause.
    ///
    /// ```swift
    /// SQL.SELECT(\.id).FROM(users)   // SELECT id FROM users
    /// ```
    func FROM(_ table: T) -> TypedFromSQLQuery<T, Row>
}

public extension FROMableQuery {
    
    /// Adds the `FROM` clause.
    ///
    /// ```swift
    /// SQL.SELECT(\.id).FROM(users)   // SELECT id FROM users
    /// ```
    func FROM(_ table: T) -> TypedFromSQLQuery<T, Row> {
        return TypedFromSQLQuery(for: table, query: query + " FROM \(T.schema)", parameters: [])
    }
}


/// A query that can be followed by `FROM` with any table.
public protocol FROMableSQLQuery: SQLQuery {
    /// Adds the `FROM` clause. Key paths in later clauses resolve against `table`.
    ///
    /// ```swift
    /// SQL.SELECT(users.id).FROM(users)   // SELECT users.id FROM users
    /// ```
    func FROM<T>(_ table: T) -> TypedFromSQLQuery<T, Void>
}


public extension FROMableSQLQuery {
    
    /// Adds the `FROM` clause. Key paths in later clauses resolve against `table`.
    ///
    /// ```swift
    /// SQL.SELECT(users.id).FROM(users)   // SELECT users.id FROM users
    /// ```
    func FROM<T>(_ table: T) -> TypedFromSQLQuery<T, Void> {
        return TypedFromSQLQuery(for: table, query: query + " FROM \(T.schema)", parameters: [])
    }
}
