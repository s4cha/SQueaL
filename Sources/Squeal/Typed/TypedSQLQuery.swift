//
//  TypedSQLQuery.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public struct TypedSQLQuery<T: Table>: SQLQuery {
    
    let schema: T
    
    public var raw: String
    
    init(schema: T, raw: String = "") {
        self.schema = schema
        self.raw = raw
    }
    
    public init(for table: T) {
        self.schema = table
        self.raw = ""
    }
}

