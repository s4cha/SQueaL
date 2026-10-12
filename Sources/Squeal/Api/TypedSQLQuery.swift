//
//  TypedSQLQuery.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

/// A query on a known table `T`.
///
/// `Row` describes what a `SELECT` of key paths returns: the selected column's type, or a tuple of types. Squeal uses it to type-check subqueries. It's `Void` for queries that don't select key paths.
public protocol TableSQLQuery<T>: SQLQuery  {
    /// The table the query reads from or writes to. Key paths in the query resolve against it.
    associatedtype T: Table
    /// The type of the selected columns, used to type-check subqueries.
    associatedtype Row = Void
    /// A value of the query's table, used to resolve key paths to columns.
    var table: T { get }
}


/// A complete query that accepts no further clauses, such as one ending in `RETURNING`.
public struct TypedSQLQuery<T: Table, Row>: TableSQLQuery {
    
    public let table: T
    public var query: String = ""
    public var parameters: [(any Encodable)?]
    
    /// Creates a query from SQL text and its parameters.
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
    
    /// Returns a column of the affected rows: `RETURNING column`.
    func RETURNING<U>(_ kp: KeyPath<T, TableColumn<T, U>>) -> TypedSQLQuery<T, Void> {
        return TypedSQLQuery<T, Void>(for: table, query: query + " RETURNING \(table[keyPath: kp].name)", parameters: parameters)
    }
    
    /// Returns columns of the affected rows: `RETURNING a, b, …`.
    func RETURNING<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSQLQuery<T, Void> {
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSQLQuery<T, Void>(for: table, query: query + " RETURNING \(columnNames.joined(separator: ", "))", parameters: parameters)
    }
    
    /// Returns every column of the affected rows: `RETURNING *`.
    ///
    /// - Parameter all: Pass `*`.
    func RETURNING(_ all: (Int, Int) -> Int) -> TypedSQLQuery<T, Void> {
        return TypedSQLQuery<T, Void>(for: table, query: query + " RETURNING *", parameters: parameters)
    }
}
