//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


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

public protocol GroupByableQuery: TableSQLQuery {
    func GROUP_BY<X>(_ keypath:  KeyPath<T, TableColumn<T, X>>) -> TypedGroupBySQLQuery<T, Row>
    func GROUP_BY<each X>(_ keypaths: repeat KeyPath<T, TableColumn<T, each X>>) -> TypedGroupBySQLQuery<T, Row>
}

public extension GroupByableQuery {
    
    func GROUP_BY<X>(_ keypath:  KeyPath<T, TableColumn<T, X>>) -> TypedGroupBySQLQuery<T, Row> {
        return TypedGroupBySQLQuery(for: table, query: query + " GROUP BY " + table[keyPath: keypath].name, parameters: parameters)
    }

    func GROUP_BY<each X>(_ keypaths: repeat KeyPath<T, TableColumn<T, each X>>) -> TypedGroupBySQLQuery<T, Row> {
        var columnNames = [String]()
        for keypath in repeat each keypaths {
            columnNames.append(table[keyPath: keypath].name)
        }
        return TypedGroupBySQLQuery(for: table, query: query + " GROUP BY " + columnNames.joined(separator: ", "), parameters: parameters)
    }
}

