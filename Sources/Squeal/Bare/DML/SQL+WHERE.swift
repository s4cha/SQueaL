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
    
    func WHERE(_ equation: SQLEquation) -> WhereSQLQuery {
        return WhereSQLQuery(query: query + " WHERE \(equation.left) \(equation.sign) \(nextDollarSign())", parameters: parameters + [equation.right])
    }
}
