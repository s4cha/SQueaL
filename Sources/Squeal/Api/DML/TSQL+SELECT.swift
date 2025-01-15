//
//  TSQL+SELECT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public struct TypedSelectSQLQuery<T: Table>: TableSQLQuery, FROMableQuery {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
        
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}


public extension SQL {

    static func SELECT<T>(_ v: SQLSelectValue, FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSelectSQLQuery(for: table, query: "SELECT \(v.rawValue)", parameters: [])
            .FROM(table)
    }
    

    static func SELECT<T, each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>, FROM table: T) -> TypedFromSQLQuery<T> {
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        
        return TypedSelectSQLQuery(for: table, query: "SELECT \(columnNames.joined(separator: ", "))", parameters: [])
            .FROM(table)
    }
    
    static func SELECT<T, each U>(_ aliases: repeat (KeyPath<T, TableColumn<T, each U>>, AS: String), FROM table: T) -> TypedFromSQLQuery<T> {
        var columnNames = [String]()
        for alias in repeat each aliases {
            columnNames.append(table[keyPath: alias.0].name + " AS \(alias.AS)")
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT \(columnNames.joined(separator: ", "))", parameters: [])
            .FROM(table)
    }
}
