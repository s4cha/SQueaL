//
//  TypedSQLQuery.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public protocol TableSQLQuery<T>: SQLQuery  {
    associatedtype T: Table
    var table: T { get }
}


public struct TypedSQLQuery<T: Table>: TableSQLQuery {
    
    public let table: T
    public var query: String = ""
    public var parameters: [(any Encodable)?]
    
    public init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
    
    init(for table: T) {
        self.table = table
        self.query = ""
        self.parameters = []
    }
}
