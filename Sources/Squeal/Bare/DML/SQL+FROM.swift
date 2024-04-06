//
//  SQL+FROM.swift
//  
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public extension SQLQuery {
    
    func FROM(_ tableName: String) -> SQLQuery {
        return BareSQLQuery(query: query + " FROM \(tableName)", parameters: [])
    }
    
    func FROM(_ table: Table) -> SQLQuery {
        return BareSQLQuery(query: query + " FROM \(table.tableName)", parameters: [])
    }
}

public extension SelectSQLQuery  {
    func FROM(_ tableName: String) -> FromSQLQuery {
        return FromSQLQuery(query: query + " FROM \(tableName)")
    }
    
    func FROM(_ table: Table) -> FromSQLQuery {
        return FromSQLQuery(query: query + " FROM \(table.tableName)")
    }
}

public struct FromSQLQuery: SQLQuery {
    public let query: String
    public var parameters: [Any]
    
    init(query: String) {
        self.query = query
        self.parameters = []
    }
}
