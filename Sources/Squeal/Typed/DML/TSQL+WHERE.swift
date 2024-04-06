//
//  SQL+WHERE.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public struct TypedWhereSQLQuery<T: Table>: SQLQuery {
    let table: T
    public var raw: String
    

    init(for table: T, raw: String) {
        self.table = table
        self.raw = raw
    }
}


public extension TypedFromSQLQuery {

    func WHERE<U>(_ kp: KeyPath<T, Field<U>>, in values: [String]) -> TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table, raw: raw + " " + "WHERE" + " \(table[keyPath: kp].name)" + " in (\(values.map{"'\($0)'"}.joined(separator: ", ")))")
    }
    
    func WHERE(_ equation: SQLEquation) -> TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table, raw: raw + " WHERE \(equation.left) \(equation.sign) \(equation.right)")
    }
    
    func WHERE<Y>(_ equation: KPSQLEquation<T, Y>) -> TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table, raw: raw + " WHERE \(table[keyPath: equation.left].name) \(equation.sign) \(equation.right)")
    }
    
    func WHERE<Y>(_ equation: KPSQLEquation<T, Y>) -> TypedWhereSQLQuery<T> where Y == String {
        return TypedWhereSQLQuery(for: table, raw: raw + " WHERE \(table[keyPath: equation.left].name) \(equation.sign) '\(equation.right)'")
    }
    
    func WHERE<Y>(_ equation: KPSQLEquation<T, Y?>) -> TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table, raw: raw + " WHERE \(table[keyPath: equation.left].name) \(equation.sign) \(equation.right!)")
    }
    
    func WHERE<Y>(_ equation: KPSQLEquation<T, Y?>) -> TypedWhereSQLQuery<T> where Y == String {
        return TypedWhereSQLQuery(for: table, raw: raw + " WHERE \(table[keyPath: equation.left].name) \(equation.sign) '\(equation.right!)'")
    }
}

