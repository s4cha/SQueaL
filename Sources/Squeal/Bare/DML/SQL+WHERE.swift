//
//  SQL+WHERE.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public struct WhereSQLQuery: SQLQuery {
    public let raw: String
}

public extension FromSQLQuery {
    func WHERE(_ clause: String) -> WhereSQLQuery {
        return WhereSQLQuery(raw: raw + " WHERE \(clause)")
    }
    
    func WHERE(_ column: String, equals value: Any) -> WhereSQLQuery {
        return WhereSQLQuery(raw: raw + " WHERE \(column) = \(value)")
    }
    
    func WHERE(_ equation: SQLEquation) -> WhereSQLQuery {
        return WhereSQLQuery(raw: raw + " WHERE \(equation.left) \(equation.sign) \(equation.right)")
    }
}
