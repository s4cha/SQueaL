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

public struct TypedWhereSQLQuery<T: Table, Row>: WHEREClause {
    
    
    public let table: T
    public var query: String = ""
    public var parameters: [(any Encodable)?]
        
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }

    public func RETURNING<U>(_ kp: KeyPath<T, TableColumn<T, U>>) -> TypedSQLQuery<T, Void> {
        return TypedSQLQuery(for: table, query: query + " RETURNING \(table[keyPath: kp].name)", parameters: parameters)
    }

    public func RETURNING<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSQLQuery<T, Void> {
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSQLQuery(for: table, query: query + " RETURNING \(columnNames.joined(separator: ", "))", parameters: parameters)
    }

    public func RETURNING(_ all: (Int, Int) -> Int) -> TypedSQLQuery<T, Void> {
        return TypedSQLQuery(for: table, query: query + " RETURNING *", parameters: parameters)
    }
}

public struct PartialTypedWhereSQLQuery<T: Table, U, Row>: TableSQLQuery {
    
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
    var IS_NULL: TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table,
                                  query: query + " WHERE \(table[keyPath: keypath].name) IS NULL",
                                  parameters: parameters)
    }
    
    var IS_NOT_NULL: TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table,
                                  query: query + " WHERE \(table[keyPath: keypath].name) IS NOT NULL",
                                  parameters: parameters)
    }
}

public protocol WHEREableQuery: TableSQLQuery {
    func WHERE<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, IN values: [U]) -> TypedWhereSQLQuery<T, Row>
    func WHERE<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, NOT_IN values: [U]) -> TypedWhereSQLQuery<T, Row>
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T,U>>, LIKE value: String) -> TypedWhereSQLQuery<T, Row>
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T,U>>, NOT_LIKE value: String) -> TypedWhereSQLQuery<T, Row>
    func WHERE<U: Comparable & Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, BETWEEN low: U, AND high: U) -> TypedWhereSQLQuery<T, Row>
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T, Row>
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y?>) -> TypedWhereSQLQuery<T, Row>
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T,U>>) -> PartialTypedWhereSQLQuery<T, U, Row>
    func WHERE(_ rawString: String) -> TypedWhereSQLQuery<T, Row>
    func WHERE<U: Table, Y: Encodable>(_ predicate: TableColumnPredicate<U, Y>) -> TypedWhereSQLQuery<T, Row>
    func WHERE<U: Table, Y>(_ predicate: SQLPredicate<U, Y>) -> TypedWhereSQLQuery<T, Row>
}


public extension WHEREableQuery {
    
    func WHERE<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, IN values: [U]) -> TypedWhereSQLQuery<T, Row> {
        var pNumber = parameterNumber()
        func nextParamSign() -> String {
            pNumber += 1
            return "$\(pNumber)"
        }
        return TypedWhereSQLQuery(for: table, query: query + " WHERE" + " \(table[keyPath: kp].name)" + " IN (\(values.map{_ in "\(nextParamSign())"}.joined(separator: ", ")))", parameters: parameters + values)
    }
    
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T, U>>, LIKE value: String) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(table[keyPath: kp].name) like \(nextDollarSign())", parameters: parameters + [value])
    }

    func WHERE<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, NOT_IN values: [U]) -> TypedWhereSQLQuery<T, Row> {
        var pNumber = parameterNumber()
        func nextParamSign() -> String {
            pNumber += 1
            return "$\(pNumber)"
        }
        return TypedWhereSQLQuery(for: table, query: query + " WHERE" + " \(table[keyPath: kp].name)" + " NOT IN (\(values.map{_ in "\(nextParamSign())"}.joined(separator: ", ")))", parameters: parameters + values)
    }

    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T, U>>, NOT_LIKE value: String) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(table[keyPath: kp].name) NOT LIKE \(nextDollarSign())", parameters: parameters + [value])
    }

    func WHERE<U: Comparable & Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, BETWEEN low: U, AND high: U) -> TypedWhereSQLQuery<T, Row> {
        let p1 = nextDollarSign()
        let p2 = "$\(parameterNumber() + 2)"
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(table[keyPath: kp].name) BETWEEN \(p1) AND \(p2)", parameters: parameters + [low, high])
    }

    func WHERE<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T, Row> {
        let q = query + " WHERE \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table,
                                  query: q,
                                  parameters: parameters + [predicate.right])
    }
    
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y?>) -> TypedWhereSQLQuery<T, Row> {
        let q = query + " WHERE \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters:  parameters + [predicate.right!])
    }
    
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T, U>>) -> PartialTypedWhereSQLQuery<T, U, Row> {
        return PartialTypedWhereSQLQuery(for: table, query: query, parameters: parameters, keypath: kp)
    }
    
    func WHERE<U: Table, Y: Encodable>(_ predicate: TableColumnPredicate<U, Y>) -> TypedWhereSQLQuery<T, Row> {
        let q = query + " WHERE \(predicate.column.tableName).\(predicate.column.name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }
    
    func WHERE<U: Table, Y>(_ predicate: SQLPredicate<U, Y>) -> TypedWhereSQLQuery<T, Row> {
        let otherTable = U()
        let column = otherTable[keyPath: predicate.left]
        let q = query + " WHERE \(column.tableName).\(column.name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }
    
    func WHERE(_ rawString: String) -> TypedWhereSQLQuery<T, Row> {
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

