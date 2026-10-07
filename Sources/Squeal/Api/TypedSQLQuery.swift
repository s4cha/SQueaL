//
//  TypedSQLQuery.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public protocol TableSQLQuery<T>: SQLQuery  {
    associatedtype T: Table
    associatedtype Row = Void
    var table: T { get }
}


public struct TypedSQLQuery<T: Table, Row>: TableSQLQuery {
    
    public let table: T
    public var query: String = ""
    public var parameters: [(any Encodable)?]
    
    public init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}

// MARK: - RETURNING expressions

/// ` RETURNING a, b, …` for fields that may mix table columns (`table.column`) and `RawSQL` expressions.
func returningClause<each F: SelectField>(_ fields: repeat each F) -> String {
    var names = [String]()
    for field in repeat each fields {
        names.append(field.toString())
    }
    return " RETURNING \(names.joined(separator: ", "))"
}

// MARK: - RETURNING support (e.g. after INSERT ... ON CONFLICT ... DO ... RETURNING)

public extension TypedSQLQuery {
    
    func RETURNING<U>(_ kp: KeyPath<T, TableColumn<T, U>>) -> TypedSQLQuery<T, Void> {
        return TypedSQLQuery<T, Void>(for: table, query: query + " RETURNING \(table[keyPath: kp].name)", parameters: parameters)
    }
    
    func RETURNING<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSQLQuery<T, Void> {
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSQLQuery<T, Void>(for: table, query: query + " RETURNING \(columnNames.joined(separator: ", "))", parameters: parameters)
    }
    
    func RETURNING(_ all: (Int, Int) -> Int) -> TypedSQLQuery<T, Void> {
        return TypedSQLQuery<T, Void>(for: table, query: query + " RETURNING *", parameters: parameters)
    }
}
