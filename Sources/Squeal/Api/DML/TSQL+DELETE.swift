//
//  TypedSQL + DELETE.swift
//  
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation

public extension SQL {
    /// Starts a `DELETE` from a table. Equivalent to ``DELETE(FROM:)``.
    ///
    /// ```swift
    /// SQL.DELETE_FROM(posts).WHERE(\.id == id)   // DELETE FROM posts WHERE id = $1
    /// ```
    static func DELETE_FROM<T>(_ table: T) -> TypedDeleteSQLQuery<T> {
        return TypedDeleteSQLQuery(for: table)
    }
    
    /// Starts a `DELETE` from a table.
    ///
    /// ```swift
    /// SQL.DELETE(FROM: posts).WHERE(\.likes < 1).RETURNING(\.id)
    /// // DELETE FROM posts WHERE likes < $1 RETURNING id
    /// ```
    ///
    /// The result isn't a query you can run until you add `WHERE`, so a `DELETE` can't
    /// accidentally remove every row. See ``TypedDeleteSQLQuery``.
    static func DELETE<T>(FROM table: T) -> TypedDeleteSQLQuery<T> {
        return TypedDeleteSQLQuery(for: table)
    }
    
    /// Starts a `DELETE`, to be followed by `FROM`: `SQL.DELETE.FROM(posts)`.
    static var DELETE: DeleteSQLQuery {
        return DeleteSQLQuery(query: "DELETE", parameters: [])
    }
}


/// A `DELETE` waiting for its `FROM` clause.
public struct DeleteSQLQuery: SQLFragment {
    
    public var query: String
    public var parameters: [(any Encodable)?]
        
    init(query: String, parameters: [(any Encodable)?]) {
        self.query = query
        self.parameters = parameters
    }

    /// Adds the table to delete from. Follow it with `WHERE`.
    public func FROM<T>(_ table: T) -> TypedDeleteSQLQuery<T> {
        return TypedDeleteSQLQuery(for: table)
    }
}

/// A `DELETE FROM table` waiting for its `WHERE` clause.
///
/// It isn't an ``SQLQuery``, so you can't run it, or pass it to `PostgresClient.query(_:)`,
/// until you add a `WHERE`. A `DELETE` that would remove every row doesn't compile:
///
/// ```swift
/// try await client.query(SQL.DELETE(FROM: posts))
/// // error: 'query(_:logger:file:line:)' is unavailable: Add a WHERE clause:
/// //        this DELETE would remove every row. …
///
/// try await client.query(SQL.DELETE(FROM: posts).WHERE(\.likes < 1))   // OK
/// ```
///
/// To delete every row on purpose, say so with a condition that's always true:
/// `.WHERE(SQLExpr("true"))`.
public struct TypedDeleteSQLQuery<T: Table>: TableSQLFragment, WHEREableQuery {
    public typealias Row = Void

    public let table: T
    public let query: String
    public let parameters: [(any Encodable)?] = []

    init(for table: T) {
        self.table = table
        self.query = "DELETE FROM \(T.schema)"
    }
}
