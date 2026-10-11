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
    static func DELETE_FROM<T>(_ table: T) -> TypedFromSQLQuery<T, Void> {
        return TypedSelectSQLQuery<T, Void>(for: table, query: "DELETE", parameters: []).FROM(table)
    }
    
    /// Starts a `DELETE` from a table.
    ///
    /// ```swift
    /// SQL.DELETE(FROM: posts).WHERE(\.likes < 1).RETURNING(\.id)
    /// // DELETE FROM posts WHERE likes < $1 RETURNING id
    /// ```
    ///
    /// > Warning: Without a `WHERE`, this deletes every row in the table.
    static func DELETE<T>(FROM table: T) -> TypedFromSQLQuery<T, Void> {
        return TypedSelectSQLQuery<T, Void>(for: table, query: "DELETE", parameters: []).FROM(table)
    }
    
    /// Starts a `DELETE`, to be followed by `FROM`: `SQL.DELETE.FROM(posts)`.
    static var DELETE: DeleteSQLQuery {
        return DeleteSQLQuery(query: "DELETE", parameters: [])
    }
}


/// A `DELETE` waiting for its `FROM` clause.
public struct DeleteSQLQuery: SQLQuery, FROMableSQLQuery {
    
    public var query: String
    public var parameters: [(any Encodable)?]
        
    init(query: String, parameters: [(any Encodable)?]) {
        self.query = query
        self.parameters = parameters
    }
}
