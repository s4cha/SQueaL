//
//  SQL+WHERE.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public struct TypedWhereSQLQuery<T: Table>: SQLQuery {
    let table: T
    public var query: String = ""
    public var parameters = [Any]()
        
    init(for table: T, query: String, parameters: [Any]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}


public extension TypedFromSQLQuery {

    func WHERE<U>(_ kp: KeyPath<T, Field<U>>, in values: [String]) -> TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table, query: query + " WHERE" + " \(table[keyPath: kp].name)" + " in (\(values.map{"'\($0)'"}.joined(separator: ", ")))", parameters: []) //TODO fix
    }
    
    func WHERE(_ equation: SQLEquation) -> TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(equation.left) \(equation.sign) \(nextDollarSign())", parameters: parameters + [equation.right])
    }
    
    func WHERE<Y>(_ equation: KPSQLEquation<T, Y>) -> TypedWhereSQLQuery<T> {
        let q = query + " WHERE \(table[keyPath: equation.left].name) \(equation.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table,
                                  query: q,
                                  parameters: parameters + [equation.right])
    }
    
//    func WHERE<Y>(_ equation: KPSQLEquation<T, Y>) -> TypedWhereSQLQuery<T> where Y == String {
//        return TypedWhereSQLQuery(for: table, raw: raw + " WHERE \(table[keyPath: equation.left].name) \(equation.sign) '\(equation.right)'")
//    }
    
    func WHERE<Y>(_ equation: KPSQLEquation<T, Y?>) -> TypedWhereSQLQuery<T> {
//        return TypedWhereSQLQuery(for: table, raw: raw + " WHERE \(table[keyPath: equation.left].name) \(equation.sign) \(equation.right!)")
        let q = query + " WHERE \(table[keyPath: equation.left].name) \(equation.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters:  parameters + [equation.right!])
    }
    
//    func WHERE<Y>(_ equation: KPSQLEquation<T, Y?>) -> TypedWhereSQLQuery<T> where Y == String {
//        return TypedWhereSQLQuery(for: table, raw: raw + " WHERE \(table[keyPath: equation.left].name) \(equation.sign) '\(equation.right!)'")
//    }
}

