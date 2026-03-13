//
//  TypedSQL + DELETE.swift
//  
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation

public extension SQL {
    static func DELETE_FROM<T>(_ table: T) -> TypedFromSQLQuery<T, Void> {
        return TypedSelectSQLQuery<T, Void>(for: table, query: "DELETE", parameters: []).FROM(table)
    }
    
    static func DELETE<T>(FROM table: T) -> TypedFromSQLQuery<T, Void> {
        return TypedSelectSQLQuery<T, Void>(for: table, query: "DELETE", parameters: []).FROM(table)
    }
    
    static var DELETE: DeleteSQLQuery {
        return DeleteSQLQuery(query: "DELETE", parameters: [])
    }
}


public struct DeleteSQLQuery: SQLQuery, FROMableSQLQuery {
    
    public var query: String
    public var parameters: [(any Encodable)?]
        
    init(query: String, parameters: [(any Encodable)?]) {
        self.query = query
        self.parameters = parameters
    }
}
