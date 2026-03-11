//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public protocol OrderByClause: TableSQLQuery, LimitableQuery, OffsetableQuery {
    
}

public struct TypedOrderBySQLQuery<T: Table, Row>: OrderByClause {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
    
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
    
    public var ASC: TypedOrderBySQLQuery {
        return TypedOrderBySQLQuery(for: table, query: query + " ASC", parameters: parameters)
    }
    
    public var DESC: TypedOrderBySQLQuery {
        return TypedOrderBySQLQuery(for: table, query: query + " DESC", parameters: parameters)
    }
}

public protocol OrderByableQuery: TableSQLQuery {
    func ORDER_BY<X>(_ keypath:  KeyPath<T, TableColumn<T, X>>) -> TypedOrderBySQLQuery<T, Row>
    func ORDER_BY<X>(_ keypath:  KeyPath<T, TableColumn<T, X>>, _ order: OrderByOrder) -> TypedOrderBySQLQuery<T, Row>
    func ORDER_BY<each U>(_ tuple: repeat (KeyPath<T, TableColumn<T, each U>>, OrderByOrder)) -> TypedOrderBySQLQuery<T, Row>
}

public extension OrderByableQuery {
    
    func ORDER_BY<X>(_ keypath:  KeyPath<T, TableColumn<T, X>>) -> TypedOrderBySQLQuery<T, Row> {
        return TypedOrderBySQLQuery(for: table, query: query + " ORDER BY " + table[keyPath: keypath].name, parameters: parameters)
    }
    
    func ORDER_BY<X>(_ keypath:  KeyPath<T, TableColumn<T, X>>, _ order: OrderByOrder) -> TypedOrderBySQLQuery<T, Row> {
        return TypedOrderBySQLQuery(for: table, query: query + " ORDER BY " + table[keyPath: keypath].name + " " + order.rawValue, parameters: parameters)
    }
    
    func ORDER_BY<each U>(_ orders: repeat (KeyPath<T, TableColumn<T, each U>>, OrderByOrder)) -> TypedOrderBySQLQuery<T, Row> {
        var columnNames = [String]()
        for order in repeat each orders {
            columnNames.append(table[keyPath: order.0].name + " \(order.1 == .ASC ? "ASC" : "DESC")")
        }
        return TypedOrderBySQLQuery(for: table, query: query + " ORDER BY \(columnNames.joined(separator: ", "))", parameters: parameters)
    }
}

public enum OrderByOrder: String {
    case ASC
    case DESC
}
