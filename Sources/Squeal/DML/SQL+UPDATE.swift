//
//  File.swift
//  
//
//  Created by Sacha Durand Saint Omer on 31/03/2024.
//

import Foundation


//UPDATE Customers
//SET ContactName = 'Alfred Schmidt', City= 'Frankfurt'
//WHERE CustomerID = 1;


public extension String {
    
    func UPDATE<T, Y>(_ table: T, SET keypath: KeyPath<T, Field<Y>>, value: Y?) -> TypedFromSQLQuery<T> {
        let v = value == nil ? "NULL" : "'\(value!)'"
        return TypedFromSQLQuery(for: table, raw: "UPDATE \(table.tableName) SET \(table[keyPath: keypath].name) = \(v)")
    }
    
//    func UPDATE<T, Y>(_ table: T, SET keypath: KeyPath<T, Field<Y>>, value: Y?, 
//                      WHERE: String) -> TypedFromSQLQuery<T> {
//        let v = value == nil ? "NULL" : "'\(value)'"
//        return TypedFromSQLQuery(for: table, raw: "UPDATE \(table.tableName) SET \(table[keyPath: keypath].name) = \(v) WHERE \(WHERE)")
//    }
    
//    func UPDATE<T, Y>(_ table: T, SET keypath: KeyPath<T, Field<Y>>, value: Y, WHERE: String) -> TypedUpdateSQLQuery<T> {
//        return TypedUpdateSQLQuery(for: table, raw: "UPDATE \(table.tableName) SET \(table[keyPath: keypath].name) = '\(value)' WHERE \(WHERE)")
//    }
    
//    func UPDATE<T>(_ table: T, SET: String, WHERE: String) -> TypedUpdateSQLQuery<T> {
//        return TypedUpdateSQLQuery(for: table, raw: "UPDATE \(table.tableName) SET \(SET) WHERE \(WHERE)")
//    }
}

public struct TypedUpdateSQLQuery<T: Table>: CustomStringConvertible {
    public var description: String { return raw }
    
    let table: T
    public var raw: String
    

    init(for table: T, raw: String) {
        self.table = table
        self.raw = raw
    }
}
