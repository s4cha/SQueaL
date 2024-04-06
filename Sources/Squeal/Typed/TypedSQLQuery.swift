//
//  TypedSQLQuery.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public struct TypedSQLQuery<T: Table>: SQLQuery {
    
    let table: T
    public var query: String = ""
    public var parameters = [Any]()
        
    init(for table: T, query: String, parameters: [Any]) {
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

