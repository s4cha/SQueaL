//
//  TSQL+SELECT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public struct TypedSelectSQLQuery<T: Table>: SQLQuery {
    
    let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
        
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}


public extension SQL {
    
    static func SELECT<T>(_ columns: [any AnyField], FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSelectSQLQuery(for: table, query: "SELECT \(columns.map { $0.name}.joined(separator: ", "))", parameters: [])
            .FROM(table)
    }
    
    static func SELECT<T>(_ columns: String, FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSelectSQLQuery(for: table, query: "SELECT \(columns)", parameters: [])
            .FROM(table)
    }
    
    static func SELECT<T>(_ v: SQLSelectValue, FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSelectSQLQuery(for: table, query: "SELECT \(v.rawValue)", parameters: [])
            .FROM(table)
    }
    
    static func SELECT<T, X>(_ keypath:  KeyPath<T, Field<X>>, FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSelectSQLQuery(for: table, query: "SELECT" + " " + table[keyPath: keypath].name, parameters: [])
            .FROM(table)
    }
    
    static func SELECT<X, Y, T>(_ keypath1:  KeyPath<T, Field<X>>, _ keypath2:  KeyPath<T, Field<Y>>, FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSelectSQLQuery(for: table, query: "SELECT" + " " + table[keyPath: keypath1].name + ", " + table[keyPath: keypath2].name, parameters: [])
            .FROM(table)
    }

    static func SELECT<T, each U>(_ columns: repeat KeyPath<T, Field<each U>>, FROM table: T) -> TypedFromSQLQuery<T> {
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        
        return TypedSelectSQLQuery(for: table, query: "SELECT \(columnNames.joined(separator: ", "))", parameters: [])
            .FROM(table)
    }
}
