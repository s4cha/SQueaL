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

public struct SelectSQLQuery: SQLQuery, FROMableSQLQuery {
    
    public var query: String
    public var parameters: [(any Encodable)?]
        
    init(query: String, parameters: [(any Encodable)?]) {
        self.query = query
        self.parameters = parameters
    }
}


public extension TSQL {
    
    static func SELECT(_ function: (Int, Int) -> Int) -> TypedSelectSQLQuery<T> {
        let table = T()
        return TypedSelectSQLQuery(for: table, query: "SELECT *", parameters: [])
    }
    
    static func SELECT<each Z: SelectField>(_ fields: repeat each Z) -> SelectSQLQuery {
        var fieldNames = [String]()
        for field in repeat each fields {
            fieldNames.append(field.toString())
        }
        return SelectSQLQuery(query: "SELECT \(fieldNames.joined(separator: ", "))", parameters: [])
    }
    
    static func SELECT<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSelectSQLQuery<T> {
        let table = T()
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT \(columnNames.joined(separator: ", "))", parameters: [])
    }
    
    static func SELECT_DISTINCT<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSelectSQLQuery<T> {
        let table = T()
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT DISTINCT \(columnNames.joined(separator: ", "))", parameters: [])
    }
    
    static func SELECT<each U>(_ aliases: repeat (KeyPath<T, TableColumn<T, each U>>, AS: String)) -> TypedSelectSQLQuery<T> {
        let table = T()
        var columnNames = [String]()
        for alias in repeat each aliases {
            columnNames.append(table[keyPath: alias.0].name + " AS \(alias.AS)")
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT \(columnNames.joined(separator: ", "))", parameters: [])
    }
    
    static func SELECT_DISTINCT<each U>(_ aliases: repeat (KeyPath<T, TableColumn<T, each U>>, AS: String)) -> TypedSelectSQLQuery<T> {
        let table = T()
        var columnNames = [String]()
        for alias in repeat each aliases {
            columnNames.append(table[keyPath: alias.0].name + " AS \(alias.AS)")
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT DISTINCT \(columnNames.joined(separator: ", "))", parameters: [])
    }
    


}

public extension SQL {
    
    static func SELECT(_ function: (Int, Int) -> Int) -> SelectSQLQuery {
        return SelectSQLQuery(query: "SELECT *", parameters: [])
    }
    
    static func SELECT<each Z: SelectField>(_ fields: repeat each Z) -> SelectSQLQuery {
        var fieldNames = [String]()
        for field in repeat each fields {
            fieldNames.append(field.toString())
        }
        return SelectSQLQuery(query: "SELECT \(fieldNames.joined(separator: ", "))", parameters: [])
    }
 
    static func SELECT<T, each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSelectSQLQuery<T> {
        let table = T()
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT \(columnNames.joined(separator: ", "))", parameters: [])
    }
    
    static func SELECT_DISTINCT<T, each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSelectSQLQuery<T> {
        let table = T()
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT DISTINCT \(columnNames.joined(separator: ", "))", parameters: [])
    }
     
    static func SELECT<T, each U>(_ aliases: repeat (KeyPath<T, TableColumn<T, each U>>, AS: String)) -> SelectSQLQuery {
        let table = T()
        var columnNames = [String]()
        for alias in repeat each aliases {
            columnNames.append(table[keyPath: alias.0].name + " AS \(alias.AS)")
        }
        return SelectSQLQuery(query: "SELECT \(columnNames.joined(separator: ", "))", parameters: [])
    }
    
    static func SELECT_DISTINCT<T, each U>(_ aliases: repeat (KeyPath<T, TableColumn<T, each U>>, AS: String)) -> SelectSQLQuery {
        let table = T()
        var columnNames = [String]()
        for alias in repeat each aliases {
            columnNames.append(table[keyPath: alias.0].name + " AS \(alias.AS)")
        }
        return SelectSQLQuery(query: "SELECT DISTINCT \(columnNames.joined(separator: ", "))", parameters: [])
    }
}



public protocol SelectField {
    func toString() -> String
}


public struct COUNT {
    public let string: String
    
    public init(_ function: (Int, Int) -> Int) {
        self.string =  "COUNT(*)"
    }
    
    public init<T, Y>(_ column: TableColumn<T, Y>) {
        self.string = "COUNT(\(column.tableName).\(column.name))"
    }
    
    public init<T, Y>(_ column: KeyPath<T, TableColumn<T, Y>>) where T: Table {
        let table = T()
        self.string = "COUNT(\(table[keyPath: column].name))"
    }
}

extension TableColumn: SelectField {
    public func toString() -> String {
        return "\(tableName).\(name)"
    }
}


extension COUNT: SelectField {
    public func toString() -> String {
        return string
    }
}

