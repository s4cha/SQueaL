//
//  SQLQueryBuilder.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public class SQLQueryBuilder {
    
    public init() {}
    
    public func query() -> SQLQuery {
        return BareSQLQuery(raw: "")
    }
    
    public func query<T: Table>(for table: T) -> TypedSQLQuery<T> {
        return TypedSQLQuery(schema: table)
    }
}


public class Squeal {
    static func query() -> StartSQLQuery {
        return StartSQLQuery()
    }
    
}

public struct StartSQLQuery {
}



//struct StartSQLQuery { }


