//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public struct LimitSQLQuery: SQLQuery {
    public let raw: String
    
    init(query: SQLQuery, limit: Int) {
        raw = query.raw + " LIMIT \(limit)"
    }
}


public extension FromSQLQuery {
    
    func LIMIT(_ value: Int) -> LimitSQLQuery {
        return LimitSQLQuery(query: self, limit: value)
    }
}

public extension WhereSQLQuery {
    
    func LIMIT(_ value: Int) -> LimitSQLQuery {
        return LimitSQLQuery(query: self, limit: value)
    }
}


