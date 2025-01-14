//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public protocol OrderByClause: TableSQLQuery, LimitableQuery {
    
}

public struct TypedOrderBySQLQuery<T: Table>: OrderByClause {
    
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
    func ORDER_BY<X>(_ keypath:  KeyPath<T, Field<X>>) -> TypedOrderBySQLQuery<T>
    func ORDER_BY<X>(_ keypath:  KeyPath<T, Field<X>>, _ order: OrderByOrder) -> TypedOrderBySQLQuery<T>
}

public extension OrderByableQuery {
    
    func ORDER_BY<X>(_ keypath:  KeyPath<T, Field<X>>) -> TypedOrderBySQLQuery<T> {
        return TypedOrderBySQLQuery(for: table, query: query + " ORDER BY " + table[keyPath: keypath].name, parameters: parameters)
    }
    
    func ORDER_BY<X>(_ keypath:  KeyPath<T, Field<X>>, _ order: OrderByOrder) -> TypedOrderBySQLQuery<T> {
        return TypedOrderBySQLQuery(for: table, query: query + " ORDER BY " + table[keyPath: keypath].name + " " + order.rawValue, parameters: parameters)
    }
}

public enum OrderByOrder: String {
    case ASC
    case DESC
}
