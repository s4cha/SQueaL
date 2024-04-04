//
//  TSQL+SELECT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public struct TypedSelectSQLQuery<T: Table>: SQLQuery {
    
    let table: T
    public var raw: String
    
    init(for table: T, raw: String) {
        self.table = table
        self.raw = raw
    }
}


public extension String {
    
    func SELECT<T>(_ columns: [any AnyField], FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSQLQuery(for: table).SELECT(columns).FROM(table)
    }
    
    func SELECT<T>(_ columns: String, FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSQLQuery(for: table).SELECT(columns).FROM(table)
    }
    
    func SELECT<T>(_ v: SQLSelectValue, FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSQLQuery(for: table).SELECT(v).FROM(table)
    }
    
    func SELECT<T, X>(_ keypath:  KeyPath<T, Field<X>>, FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSQLQuery(for: table).SELECT(keypath).FROM(table)
    }
    
    func SELECT<X, Y, T>(_ keypath1:  KeyPath<T, Field<X>>, _ keypath2:  KeyPath<T, Field<Y>>, FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSelectSQLQuery(for: table, raw: "SELECT" + " " + table[keyPath: keypath1].name + ", " + table[keyPath: keypath1].name)
            .FROM(table)
    }
    
    func DELETE<T>(FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSQLQuery(for: table).DELETE().FROM(table)
    }
}


public extension TypedSQLQuery {
    
    func SELECT(_ columns: [any AnyField]) -> TypedSelectSQLQuery<T> {
        return TypedSelectSQLQuery(for: schema, raw: "SELECT \(columns.map { $0.name}.joined(separator: ", "))")
    }
    
    func SELECT(_ string: String) -> TypedSelectSQLQuery<T> {
        return TypedSelectSQLQuery(for: schema, raw: "SELECT \(string)")
    }
    
    func SELECT(_ v: SQLSelectValue) -> TypedSelectSQLQuery<T> {
        return TypedSelectSQLQuery(for: schema, raw: "SELECT \(v.rawValue)")
    }
    
    func SELECT<X>(_ keypath:  KeyPath<T, Field<X>>) -> TypedSelectSQLQuery<T> {
        return TypedSelectSQLQuery(for: schema, raw: "SELECT" + " " + schema[keyPath: keypath].name)
           // .FROM(self.schema)
    }
    
    func SELECT<X, Y>(_ keypath1:  KeyPath<T, Field<X>>, _ keypath2:  KeyPath<T, Field<Y>>) -> TypedSelectSQLQuery<T> {
        return TypedSelectSQLQuery(for: schema, raw: "SELECT" + " " + schema[keyPath: keypath1].name + ", " + schema[keyPath: keypath1].name)
           // .FROM(self.schema)
    }
}




