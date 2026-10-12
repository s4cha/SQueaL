//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


/// A query after its `GROUP BY` clause. Next, you can add `HAVING`, `ORDER_BY`, `LIMIT` or `OFFSET`.
public struct TypedGroupBySQLQuery<T: Table, Row>: TableSQLQuery, HavingableQuery, LimitableQuery, OffsetableQuery, OrderByableQuery {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
    
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}

/// A query that can be followed by a `GROUP BY` clause.
public protocol GroupByableQuery: TableSQLQuery {
    /// Groups rows by a column: `GROUP BY column`.
    func GROUP_BY<X>(_ keypath:  KeyPath<T, TableColumn<T, X>>) -> TypedGroupBySQLQuery<T, Row>
    /// Groups rows by several columns: `GROUP BY a, b, …`.
    ///
    /// ```swift
    /// SQL.SELECT(posts.author_id, COUNT(*)).FROM(posts).GROUP_BY(\.author_id)
    /// ```
    func GROUP_BY<each X>(_ keypaths: repeat KeyPath<T, TableColumn<T, each X>>) -> TypedGroupBySQLQuery<T, Row>
}

public extension GroupByableQuery {
    
    /// Groups rows by a column: `GROUP BY column`.
    func GROUP_BY<X>(_ keypath:  KeyPath<T, TableColumn<T, X>>) -> TypedGroupBySQLQuery<T, Row> {
        return TypedGroupBySQLQuery(for: table, query: query + " GROUP BY " + table[keyPath: keypath].name, parameters: parameters)
    }

    /// Groups rows by several columns: `GROUP BY a, b, …`.
    ///
    /// ```swift
    /// SQL.SELECT(posts.author_id, COUNT(*)).FROM(posts).GROUP_BY(\.author_id)
    /// ```
    func GROUP_BY<each X>(_ keypaths: repeat KeyPath<T, TableColumn<T, each X>>) -> TypedGroupBySQLQuery<T, Row> {
        var columnNames = [String]()
        for keypath in repeat each keypaths {
            columnNames.append(table[keyPath: keypath].name)
        }
        return TypedGroupBySQLQuery(for: table, query: query + " GROUP BY " + columnNames.joined(separator: ", "), parameters: parameters)
    }
}

