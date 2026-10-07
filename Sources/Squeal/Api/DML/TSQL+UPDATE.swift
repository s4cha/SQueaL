//
//  TSQL+UPDATE.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation

public struct TypedUpdateSQLQuery<T: Table, Row>: TableSQLQuery, WHEREableQuery {
    
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
    
    static func UPDATE<T, each U: Encodable>(_ table: T, SET pairs: repeat (KeyPath<T, TableColumn<T, each U>>, (each U)?)) -> TypedUpdateSQLQuery<T, Void> {
        var q = "UPDATE \(T.schema) SET "
        let table = T()
        var parameters = [Encodable]()
        var setValues = [String]()
        var nextPIndex = 0
        for pair in repeat each pairs {
            nextPIndex = nextPIndex + 1
            setValues.append(table[keyPath: pair.0].name + " = $\(nextPIndex)")
            parameters.append(pair.1)
        }
        q += setValues.joined(separator: ", ")
        return TypedUpdateSQLQuery(for: table, query: q, parameters: parameters)
    }

    /// `UPDATE table SET column = (subquery)` — the subquery must return a single row & column.
    static func UPDATE<T, U, Q: TableSQLQuery>(_ table: T, SET pair: (KeyPath<T, TableColumn<T, U>>, Q)) -> TypedUpdateSQLQuery<T, Void> where Q.Row == U {
        return update(table, column: table[keyPath: pair.0].name, subquery: pair.1)
    }

    /// `UPDATE table SET column = (subquery)` on a nullable column.
    static func UPDATE<T, U, Q: TableSQLQuery>(_ table: T, SET pair: (KeyPath<T, TableColumn<T, U?>>, Q)) -> TypedUpdateSQLQuery<T, Void> where Q.Row == U {
        return update(table, column: table[keyPath: pair.0].name, subquery: pair.1)
    }

    private static func update<T: Table>(_ table: T, column: String, subquery: some SQLQuery) -> TypedUpdateSQLQuery<T, Void> {
        // Nothing precedes the subquery, so its $n placeholders need no renumbering.
        return TypedUpdateSQLQuery(for: table, query: "UPDATE \(T.schema) SET \(column) = (\(subquery.query))", parameters: subquery.parameters)
    }
}
