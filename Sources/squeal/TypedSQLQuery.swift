//
//  TypedSQLQuery.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

struct Field<T>: AnyField {
    let name: String
}

protocol AnyField {
    var name: String { get }
}

protocol Table {
    var tableName: String { get }
    init()
}

struct TypedSQLQuery<T: Table>: SQLQuery {
    
    let schema: T
    
    var raw: String
    
    init(schema: T, raw: String = "") {
        self.schema = schema
        self.raw = raw
    }
}
