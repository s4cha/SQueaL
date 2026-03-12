//
//  SQL+OFFSET.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public struct TypedOffsetSQLQuery<T: Table, Row>: TableSQLQuery {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
    
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}


public protocol OffsetableQuery: TableSQLQuery {

    func OFFSET(_ value: Int) -> TypedOffsetSQLQuery<T, Row>
}

public extension OffsetableQuery {
    
    func OFFSET(_ value: Int) -> TypedOffsetSQLQuery<T, Row> {
        return TypedOffsetSQLQuery(for: table, query: query + " " + "OFFSET \(value)", parameters: parameters)
    }
}


