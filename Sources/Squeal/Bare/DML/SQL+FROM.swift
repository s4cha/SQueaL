//
//  SQL+FROM.swift
//  
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public extension SQLQuery {
    
    func FROM(_ tableName: String) -> SQLQuery {
        return BareSQLQuery(raw: raw + " " + "FROM \(tableName)")
    }
    
    func FROM(_ table: Table) -> SQLQuery {
        return BareSQLQuery(raw: raw + " " + "FROM \(table.tableName)")
    }
}

public extension SelectSQLQuery  {
    func FROM(_ tableName: String) -> FromSQLQuery {
        return FromSQLQuery(raw: raw + " " + "FROM \(tableName)")
    }
    
    func FROM(_ table: Table) -> FromSQLQuery {
        return FromSQLQuery(raw: raw + " " + "FROM \(table.tableName)")
    }
}

public struct FromSQLQuery: SQLQuery {
    public let raw: String
}
