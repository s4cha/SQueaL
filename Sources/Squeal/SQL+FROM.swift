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

public extension TypedSelectSQLQuery {
    
    func FROM(_ tableName: String) -> TypedFromSQLQuery<T> {
        return TypedFromSQLQuery(for: table, raw: raw + " " + "FROM \(tableName)")
    }
    
    func FROM<U: Table>(_ table: U) -> TypedFromSQLQuery<T> where T == U {
        if raw.contains("FROM") {
            return TypedFromSQLQuery(for: table, raw: raw)
        }
        return TypedFromSQLQuery(for: table, raw: raw + " " + "FROM \(table.tableName)")
    }
}

public struct FromSQLQuery: CustomStringConvertible {
    public var description: String { return raw }    
    let raw: String
}

public struct TypedFromSQLQuery<T: Table>: CustomStringConvertible {
    public var description: String { return raw }    
    
    let table: T
    public var raw: String
    

    init(for table: T, raw: String) {
        self.table = table
        self.raw = raw
    }
}


//extension SQLQuery {
//    
//    func FROM(_ table: Table.Type) -> SQLQuery {
//        return SQLQuery(schema: schema, raw: raw + " " + "FROM \(table.tableName)")
//    }
//    
////    func FROM(_ tableName: TableName) -> SQLQuery {
////        return SQLQuery(raw: self.raw + " " + "FROM \(tableName)")
////    }
////
////    func FROM(_ table: any Table.Type) -> SQLQuery {
////        return SQLQuery(raw: self.raw + " " + "FROM \(table.tableName)")
////    }
//}
