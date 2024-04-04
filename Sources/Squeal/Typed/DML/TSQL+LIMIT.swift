//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public struct TypedLimitSQLQuery<T: Table>: SQLQuery {
    
    let table: T
    public var raw: String
    
    init(for table: T, raw: String) {
        self.table = table
        self.raw = raw
    }
}

public extension TypedFromSQLQuery {
    
    func LIMIT(_ value: Int) -> TypedLimitSQLQuery<T> {
        return TypedLimitSQLQuery(for: table, raw: raw + " " + "LIMIT \(value)")
    }
}

public extension TypedWhereSQLQuery {
    
    func LIMIT(_ value: Int) -> TypedLimitSQLQuery<T> {
        return TypedLimitSQLQuery(for: table, raw: raw + " " + "LIMIT \(value)")
    }
}
