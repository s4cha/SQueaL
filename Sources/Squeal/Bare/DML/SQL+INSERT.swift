//
//  SQL+INSERT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation
import SwiftUI

public extension SQLQuery {
    func INSERT(INTO tableName: String, columns: String...) -> SQLQuery {
        return BareSQLQuery(raw: raw + "INSERT INTO \(tableName)" + " ("  + columns.joined(separator: ", ") +  ")")
    }
    
    func VALUES(_ values: String...) -> SQLQuery {
        return BareSQLQuery(raw: raw + " VALUES ("  + values.map {"'\($0)'"} .joined(separator: ", ") +  ")")
    }
}


public extension String {
    
    func INSERT<T>(INTO table: T, columns: String..., VALUES: CustomStringConvertible?...) -> TypedInsertSQLQuery<T> {
        return TypedInsertSQLQuery(for: table, raw: "INSERT INTO \(table.tableName)"
                                   + " (\(columns.joined(separator: ", ")))"
                                   + " VALUES (\(VALUES.map {"'\($0)'"}.joined(separator: ", ")))")
    }
        
    func INSERT<T, X>(INTO table: T, _ fields: Field<X>..., VALUES: CustomStringConvertible...) -> TypedInsertSQLQuery<T> {
        return TypedInsertSQLQuery(for: table, raw: "INSERT INTO \(table.tableName)"
                                   + " (\(fields.map { $0.name }.joined(separator: ", ")))"
                                   + " VALUES (\(VALUES.map {"'\($0)'"}.joined(separator: ", ")))")
    }
    
    func INSERT_INTO<T>(_ table: T, columns: String..., VALUES: CustomStringConvertible...) -> TypedInsertSQLQuery<T> {
        return TypedInsertSQLQuery(for: table, raw: "INSERT INTO \(table.tableName)"
                                   + " (\(columns.joined(separator: ", ")))"
                                   + " VALUES (\(VALUES.map {"'\($0)'"}.joined(separator: ", ")))")
    }
        
}

public extension TypedInsertSQLQuery {
    
    func VALUES(_ values: String...) -> TypedSQLQuery<T> {
        TypedSQLQuery(schema: table, raw: raw + " (\(values.map{"'\($0)'"}.joined(separator: ", ")))")
    }
    
    func RETURNING<U>(_ kp: KeyPath<T, Field<U>>) -> TypedSQLQuery<T> {
        return TypedSQLQuery(schema: table, raw: raw + " RETURNING \(table[keyPath: kp].name)")
    }
}
////    func SELECT<T>(_ v: SQLSelectValue, FROM table: T) -> TypedFromSQLQuery<T> {
////        return TypedSQLQuery(for: table).SELECT(v).FROM(table)
////    }
////    
////    func SELECT<T, X>(_ keypath:  KeyPath<T, Field<X>>, FROM table: T) -> TypedFromSQLQuery<T> {
////        return TypedSQLQuery(for: table).SELECT(keypath).FROM(table)
////    }
////    
////    func SELECT<X, Y, T>(_ keypath1:  KeyPath<T, Field<X>>, _ keypath2:  KeyPath<T, Field<Y>>, FROM table: T) -> TypedFromSQLQuery<T> {
////        return TypedSelectSQLQuery(for: table, raw: "SELECT" + " " + table[keyPath: keypath1].name + ", " + table[keyPath: keypath1].name)
////            .FROM(table)
////    }
//
//}

//INSERT INTO table_name (column1, column2, column3, ...)
//VALUES (value1, value2, value3, ...);


public struct TypedInsertSQLQuery<T: Table>: CustomStringConvertible {
    public var description: String { return raw }
    
    let table: T
    public var raw: String
    

    init(for table: T, raw: String) {
        self.table = table
        self.raw = raw
    }
}

