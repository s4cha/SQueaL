//
//  SQL+AND.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public extension WhereSQLQuery {
    func AND(_ clause: String) -> WhereSQLQuery {
        return WhereSQLQuery(raw: raw + " AND \(clause)")
    }
}

public extension TypedWhereSQLQuery {
    func AND<U>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table, raw: raw + " " + "AND" + " \(table[keyPath: kp].name)" + " = " + "\(value)" )
    }
    
    func AND<U>(_ kp: KeyPath<T, Field<U>>, equals value: U) -> TypedWhereSQLQuery<T> where U == String {
        return TypedWhereSQLQuery(for: table, raw: raw + " " + "AND" + " \(table[keyPath: kp].name)" + " = " + "'\(value)'" )
    }
    
    func AND<Y>(_ equation: KPSQLEquation<T, Y>) -> TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table, raw: raw + " AND \(table[keyPath: equation.left].name) \(equation.sign) \(equation.right)")
    }
    
    func AND<Y>(_ equation: KPSQLEquation<T, Y>) -> TypedWhereSQLQuery<T> where Y == String {
        return TypedWhereSQLQuery(for: table, raw: raw + " AND \(table[keyPath: equation.left].name) \(equation.sign) '\(equation.right)'")
    }
}


//extension SQLQuery {
//
//    func AND(_ column: ColumnName, equals value: Any) -> SQLQuery {
//        return SQLQuery(raw: self.raw + " " + "AND \(column) = \(value)")
//    }
//}
