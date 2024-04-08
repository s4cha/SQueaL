//
//  SQL+WHERE.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public struct WhereSQLQuery: SQLQuery {
    public let query: String
    public var parameters: [(any Encodable)?]
}

public extension FromSQLQuery {
    func WHERE(_ clause: String) -> WhereSQLQuery {
        return WhereSQLQuery(query: query + " WHERE \(clause)", parameters: parameters)
    }
    
    func WHERE(_ predicate: BareSQLPredicate) -> WhereSQLQuery {
        return WhereSQLQuery(query: query + " WHERE \(predicate.left) \(predicate.sign) \(nextDollarSign())", parameters: parameters + [predicate.right])
    }
}
