//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public struct LimitSQLQuery: SQLQuery {
    public let query: String
    public var parameters: [(any Encodable)?]
    
    init(sqlQuery: SQLQuery, limit: Int) {
        self.query = sqlQuery.query + " LIMIT \(limit)"
        self.parameters = sqlQuery.parameters
    }
}

public extension FromSQLQuery {
    
    func LIMIT(_ value: Int) -> LimitSQLQuery {
        return LimitSQLQuery(sqlQuery: self, limit: value)
    }
}

public extension WhereSQLQuery {
    
    func LIMIT(_ value: Int) -> LimitSQLQuery {
        return LimitSQLQuery(sqlQuery: self, limit: value)
    }
}


