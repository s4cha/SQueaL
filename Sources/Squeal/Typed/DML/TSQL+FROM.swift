//
//  SQL+FROM.swift
//  
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public struct TypedFromSQLQuery<T: Table>: SQLQuery {
    
    let table: T
    public var raw: String
    

    init(for table: T, raw: String) {
        self.table = table
        self.raw = raw
    }
}

public extension TypedSelectSQLQuery {
    
    func FROM(_ tableName: String) -> TypedFromSQLQuery<T> {
        return TypedFromSQLQuery(for: table, raw: raw + " " + "FROM \(tableName)")
    }
    
    func FROM(_ table: T) -> TypedFromSQLQuery<T> {
        if raw.contains("FROM") {
            return TypedFromSQLQuery(for: table, raw: raw)
        }
        return TypedFromSQLQuery(for: table, raw: raw + " " + "FROM \(table.tableName)")
    }
}
