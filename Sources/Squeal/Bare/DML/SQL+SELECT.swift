//
//  SQL+SELECT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public struct SelectSQLQuery: SQLQuery {
    public let query: String
    public var parameters: [(any Encodable)?]
    
    init(column: String) {
        self.query = "SELECT \(column)"
        self.parameters = []
    }
}

public extension String {
    
    func SELECT(_ v: SQLSelectValue) -> SelectSQLQuery {
        return SelectSQLQuery(column: v.rawValue)
    }
    
    func SELECT(_ string: String) -> SelectSQLQuery {
        return SelectSQLQuery(column: string)
    }
    
    func SELECT<X>(_ field:  Field<X>) -> SelectSQLQuery {
        return SelectSQLQuery(column: field.name)
    }
    
    func SELECT<X,Y>(_ field:  Field<X>, _ field2:  Field<Y>) -> SelectSQLQuery {
        return SelectSQLQuery(column: [field.name, field2.name].joined(separator: ", "))
    }
}
