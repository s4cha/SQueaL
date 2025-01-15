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
    
    static func SELECT<T>(_ function: (Int, Int) -> Int, FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSelectSQLQuery(for: table, query: "SELECT *", parameters: [])
            .FROM(table)
    }
    
    static func SELECT<T>(_ value: any SelectValue<T>, FROM table: T) -> TypedFromSQLQuery<T> {
        return TypedSelectSQLQuery(for: table, query: "SELECT \(value.string)", parameters: [])
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
    
    static func SELECT_DISTINCT<T, each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>, FROM table: T) -> TypedFromSQLQuery<T> {
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT DISTINCT \(columnNames.joined(separator: ", "))", parameters: [])
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
    
    static func SELECT_DISTINCT<T, each U>(_ aliases: repeat (KeyPath<T, TableColumn<T, each U>>, AS: String), FROM table: T) -> TypedFromSQLQuery<T> {
        var columnNames = [String]()
        for alias in repeat each aliases {
            columnNames.append(table[keyPath: alias.0].name + " AS \(alias.AS)")
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT DISTINCT \(columnNames.joined(separator: ", "))", parameters: [])
            .FROM(table)
    }
}


public protocol SelectValue<T> {
    associatedtype T
    var string: String { get }
}


public struct COUNTSelectValue<T>: SelectValue {
    public let string: String = "COUNT(*)"
}

public struct COUNTColumnSelectValue<T>: SelectValue {
    public let string: String
}

public struct COUNT<T>: SelectValue {
    public let string: String
    
    public init(_ function: (Int, Int) -> Int) {
        self.string =  "COUNT(*)"
    }
    
    public init<Y>(_ column: TableColumn<T, Y>) {
        self.string = "COUNT(\(column.name))"
    }
    
    public init<Y>(_ column: KeyPath<T, TableColumn<T, Y>>) where T: Table {
        let table = T()
        self.string = "COUNT(\(table[keyPath: column].name))"
    }
}
