//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

/// A query after its `ORDER BY` clause. Next, you can add `LIMIT` or `OFFSET`.
public protocol OrderByClause: TableSQLQuery, LimitableQuery, OffsetableQuery {
    
}

/// A query after its `ORDER BY` clause.
public struct TypedOrderBySQLQuery<T: Table, Row>: OrderByClause {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
    
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
    
    /// Sorts in ascending order: appends `ASC`.
    public var ASC: TypedOrderBySQLQuery {
        return TypedOrderBySQLQuery(for: table, query: query + " ASC", parameters: parameters)
    }
    
    /// Sorts in descending order: appends `DESC`.
    public var DESC: TypedOrderBySQLQuery {
        return TypedOrderBySQLQuery(for: table, query: query + " DESC", parameters: parameters)
    }
}

/// A query that can be followed by an `ORDER BY` clause.
public protocol OrderByableQuery: TableSQLQuery {
    /// Sorts by a column: `ORDER BY column`.
    ///
    /// To set a direction, chain `.ASC` or `.DESC` after it.
    func ORDER_BY<X>(_ keypath:  KeyPath<T, TableColumn<T, X>>) -> TypedOrderBySQLQuery<T, Row>
    /// Sorts by a column in the given direction: `ORDER BY column DESC`.
    func ORDER_BY<X>(_ keypath:  KeyPath<T, TableColumn<T, X>>, _ order: OrderByOrder) -> TypedOrderBySQLQuery<T, Row>
    /// Sorts by several columns, each in its own direction.
    ///
    /// ```swift
    /// .ORDER_BY((\.likes, .DESC), (\.title, .ASC))   // ORDER BY likes DESC, title ASC
    /// ```
    func ORDER_BY<each U>(_ tuple: repeat (KeyPath<T, TableColumn<T, each U>>, OrderByOrder)) -> TypedOrderBySQLQuery<T, Row>
}

public extension OrderByableQuery {
    
    /// Sorts by a column: `ORDER BY column`.
    ///
    /// To set a direction, chain `.ASC` or `.DESC` after it.
    func ORDER_BY<X>(_ keypath:  KeyPath<T, TableColumn<T, X>>) -> TypedOrderBySQLQuery<T, Row> {
        return TypedOrderBySQLQuery(for: table, query: query + " ORDER BY " + table[keyPath: keypath].name, parameters: parameters)
    }
    
    /// Sorts by a column in the given direction: `ORDER BY column DESC`.
    func ORDER_BY<X>(_ keypath:  KeyPath<T, TableColumn<T, X>>, _ order: OrderByOrder) -> TypedOrderBySQLQuery<T, Row> {
        return TypedOrderBySQLQuery(for: table, query: query + " ORDER BY " + table[keyPath: keypath].name + " " + order.rawValue, parameters: parameters)
    }
    
    /// Sorts by several columns, each in its own direction.
    ///
    /// ```swift
    /// .ORDER_BY((\.likes, .DESC), (\.title, .ASC))   // ORDER BY likes DESC, title ASC
    /// ```
    func ORDER_BY<each U>(_ orders: repeat (KeyPath<T, TableColumn<T, each U>>, OrderByOrder)) -> TypedOrderBySQLQuery<T, Row> {
        var columnNames = [String]()
        for order in repeat each orders {
            columnNames.append(table[keyPath: order.0].name + " \(order.1 == .ASC ? "ASC" : "DESC")")
        }
        return TypedOrderBySQLQuery(for: table, query: query + " ORDER BY \(columnNames.joined(separator: ", "))", parameters: parameters)
    }

    /// ORDER BY a column of any table (e.g. a JOINed one), qualified as `table.column`.
    func ORDER_BY<U: Table, X>(_ column: TableColumn<U, X>, _ order: OrderByOrder) -> TypedOrderBySQLQuery<T, Row> {
        return TypedOrderBySQLQuery(for: table, query: query + " ORDER BY \(column.tableName).\(column.name) \(order.rawValue)", parameters: parameters)
    }
}

/// A sort direction for `ORDER_BY`.
public enum OrderByOrder: String {
    /// Ascending order, smallest first.
    case ASC
    /// Descending order, largest first.
    case DESC
}
