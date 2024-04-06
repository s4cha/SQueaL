//
//  TSQL+AND.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public extension TypedWhereSQLQuery {
    func AND<U: Encodable>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> TypedWhereSQLQuery<T> {
        let q = query + " " + "AND" + " \(table[keyPath: kp].name)" + " = " + "\(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [value])
    }
    
//    func AND<U>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> TypedWhereSQLQuery<T> where U == String {
//        return TypedWhereSQLQuery(for: table, query: query + " " + "AND" + " \(table[keyPath: kp].name)" + " = " + "'\(value)'" )
//    }
    
    func AND<Y>(_ equation: KPSQLEquation<T, Y>) -> TypedWhereSQLQuery<T> {
        let q = query + " AND \(table[keyPath: equation.left].name) \(equation.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [equation.right])
    }
    
//    func AND<Y>(_ equation: KPSQLEquation<T, Y>) -> TypedWhereSQLQuery<T> where Y == String {
//        return TypedWhereSQLQuery(for: table, query: query + " AND \(table[keyPath: equation.left].name) \(equation.sign) '\(equation.right)'")
//    }
}
