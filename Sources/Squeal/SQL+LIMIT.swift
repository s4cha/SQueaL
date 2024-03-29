//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public extension SQLQuery {
    
    func LIMIT(_ value: Int) -> SQLQuery {
        return BareSQLQuery(raw: raw + " " + "LIMIT \(value)")
    }
}


public extension FromSQLQuery {
    
    func LIMIT(_ value: Int) -> LimitSQLQuery {
        return LimitSQLQuery(raw: raw + " " + "LIMIT \(value)")
    }
}

public extension WhereSQLQuery {
    
    func LIMIT(_ value: Int) -> LimitSQLQuery {
        return LimitSQLQuery(raw: raw + " " + "LIMIT \(value)")
    }
}

public extension TypedWhereSQLQuery {
    
    func LIMIT(_ value: Int) -> TypedLimitSQLQuery<T> {
        return TypedLimitSQLQuery(for: table, raw: raw + " " + "LIMIT \(value)")
    }
}


public struct LimitSQLQuery: CustomStringConvertible {
    public var description: String { return raw }
    let raw: String
}

public struct TypedLimitSQLQuery<T: Table>: CustomStringConvertible {
    public var description: String { return raw }
    
    let table: T
    public var raw: String
    

    init(for table: T, raw: String) {
        self.table = table
        self.raw = raw
    }
}
