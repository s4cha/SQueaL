//
//  SQL+WHERE.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

// TODO try return WHereClause?
public protocol WHEREClause: TableSQLQuery, ANDableQuery, ORableQuery, GroupByableQuery, OrderByableQuery, LimitableQuery, OffsetableQuery {
    
}

public struct TypedWhereSQLQuery<T: Table>: WHEREClause {
    
    
    public let table: T
    public var query: String = ""
    public var parameters: [(any Encodable)?]
        
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}

public struct PartialTypedWhereSQLQuery<T: Table, U>: TableSQLQuery {
    
    public let table: T
    public var query: String = ""
    public var parameters: [(any Encodable)?]
    public let keypath: KeyPath<T, TableColumn<T, U>>
        
    init(for table: T, query: String, parameters: [(any Encodable)?], keypath: KeyPath<T, TableColumn<T, U>>) {
        self.table = table
        self.query = query
        self.parameters = parameters
        self.keypath = keypath
    }
}

public extension PartialTypedWhereSQLQuery {
    var IS_NULL: TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table,
                                  query: query + " WHERE \(table[keyPath: keypath].name) IS NULL",
                                  parameters: parameters)
    }
    
    var IS_NOT_NULL: TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table,
                                  query: query + " WHERE \(table[keyPath: keypath].name) IS NOT NULL",
                                  parameters: parameters)
    }
}

public protocol WHEREableQuery: TableSQLQuery {
    func WHERE<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, IN values: [U]) -> TypedWhereSQLQuery<T>
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T,U>>, LIKE value: String) -> TypedWhereSQLQuery<T>
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T>
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y?>) -> TypedWhereSQLQuery<T>
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T,U>>) -> PartialTypedWhereSQLQuery<T, U>
    func WHERE(_ rawString: String) -> TypedWhereSQLQuery<T>
    func WHERE<U: Table, Y: Encodable>(_ predicate: TableColumnPredicate<U, Y>) -> TypedWhereSQLQuery<T>
    func WHERE<U: Table, Y>(_ predicate: SQLPredicate<U, Y>) -> TypedWhereSQLQuery<T>
}


public extension WHEREableQuery {
    
    func WHERE<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, IN values: [U]) -> TypedWhereSQLQuery<T> {
        var pNumber = parameterNumber()
        func nextParamSign() -> String {
            pNumber += 1
            return "$\(pNumber)"
        }
        return TypedWhereSQLQuery(for: table, query: query + " WHERE" + " \(table[keyPath: kp].name)" + " IN (\(values.map{_ in "\(nextParamSign())"}.joined(separator: ", ")))", parameters: parameters + values)
    }
    
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T, U>>, LIKE value: String) -> TypedWhereSQLQuery<T> {
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(table[keyPath: kp].name) like \(nextDollarSign())", parameters: parameters + [value])
    }

    func WHERE<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T> {
        let q = query + " WHERE \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table,
                                  query: q,
                                  parameters: parameters + [predicate.right])
    }
    
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y?>) -> TypedWhereSQLQuery<T> {
        let q = query + " WHERE \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters:  parameters + [predicate.right!])
    }
    
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T, U>>) -> PartialTypedWhereSQLQuery<T, U> {
        return PartialTypedWhereSQLQuery(for: table, query: query, parameters: parameters, keypath: kp)
    }
    
    func WHERE<U: Table, Y: Encodable>(_ predicate: TableColumnPredicate<U, Y>) -> TypedWhereSQLQuery<T> {
        let q = query + " WHERE \(predicate.column.tableName).\(predicate.column.name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }
    
    func WHERE<U: Table, Y>(_ predicate: SQLPredicate<U, Y>) -> TypedWhereSQLQuery<T> {
        let otherTable = U()
        let column = otherTable[keyPath: predicate.left]
        let q = query + " WHERE \(column.tableName).\(column.name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }
    
    func WHERE(_ rawString: String) -> TypedWhereSQLQuery<T> {
        let operators = [">=", "<=", "!=", ">", "<", "="]
        for op in operators {
            let parts = rawString.components(separatedBy: " \(op) ")
            if parts.count == 2 {
                let column = parts[0].trimmingCharacters(in: .whitespaces)
                let rawValue = parts[1].trimmingCharacters(in: .whitespaces)
                let value: any Encodable
                if let intValue = Int(rawValue) {
                    value = intValue
                } else if let doubleValue = Double(rawValue) {
                    value = doubleValue
                } else if (rawValue.hasPrefix("'") && rawValue.hasSuffix("'"))
                            || (rawValue.hasPrefix("\"") && rawValue.hasSuffix("\"")) {
                    value = String(rawValue.dropFirst().dropLast())
                } else {
                    value = rawValue
                }
                let q = query + " WHERE \(column) \(op) \(nextDollarSign())"
                return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [value])
            }
        }
//        // Fallback: append raw string as-is with no parameters
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(rawString)", parameters: parameters)
    }
}

