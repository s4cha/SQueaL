//
//  SQLQueryBuilder.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

class SQLQueryBuilder {
    
    func query() -> SQLQuery {
        return BareSQLQuery(raw: "")
    }
    
    func query<T: Table>(for table: T) -> TypedSQLQuery<T> {
        return TypedSQLQuery(schema: table)
    }
}
