//
//  SQL+INSERT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public extension SQL {
    
    static func INSERT<T, each U:Encodable>(INTO table: T,
                   columns: repeat KeyPath<T, Field<each U>>,
                   VALUES values: repeat each U) -> TypedInsertSQLQuery<T> {
        
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        
        var queryParams = [Encodable]()
        for v in repeat each values {
            queryParams.append(v)
        }

        let queryValues = queryParams.enumerated().map { i, _ in "$\(i+1)"}.joined(separator: ", ")
        
        let q = "INSERT INTO \(table.tableName) (\(columnNames.joined(separator: ", "))) VALUES (\(queryValues))"
        return TypedInsertSQLQuery(for: table, query: q, parameters: queryParams)
    }
    
    static func INSERT<T, each U: Encodable, X: Sequence>(
        INTO table: T,
        columns: repeat KeyPath<T, Field<each U>>,
        addValuesFrom array: X,
        mapValues: (X.Element) -> (repeat each U)) -> TypedInsertSQLQuery<T> {
        
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        
        var newParams = [(any Encodable)?]()
        var valueRows = [String]()
        var nextPIndex = 1
        for x in array {
            let tuple = mapValues(x)
            var queryParams = [Encodable]()
            for v in repeat each tuple {
                queryParams.append(v)
            }
            
            newParams += queryParams
            let queryValues = queryParams.enumerated().map { i, _ in "$\(nextPIndex + i)"}.joined(separator: ", ")
            print(queryValues)
            nextPIndex += queryParams.count
            valueRows.append("(" + queryValues + ")")
        }
        
        let valuesString = valueRows.joined(separator: ", ")
        let q = "INSERT INTO \(table.tableName) (\(columnNames.joined(separator: ", "))) VALUES \(valuesString)"
        return TypedInsertSQLQuery(for: table, query: q, parameters: newParams) // TODO
    }
    
    @available(macOS 14.0.0, *)
    static func INSERT<T, each U>(INTO table: T,
                   columns: repeat KeyPath<T, Field<each U>>) -> TypedLoneInsertSQLQuery<T, repeat each U> {
        
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        
        let q = "INSERT INTO \(table.tableName) (\(columnNames.joined(separator: ", "))) "
        return TypedLoneInsertSQLQuery(for: table, query: q, parameters: []) // TODO
    }
}

@available(macOS 14.0.0, *)
public extension TypedLoneInsertSQLQuery {
    
    func VALUES(_ values: repeat each V) -> TypedLoneInsertSQLQuery {
        var q = ""
        if query.contains("VALUES (") {
            q += ", "
        } else {
            q += "VALUES "
        }
        
        var queryParams = [Encodable]()
        for v in repeat each values {
            queryParams.append(v)
        }

        let nextPIndex = parameterNumber() + 1
        let queryValues = queryParams.enumerated().map { i, _ in "$\(nextPIndex+i)"}.joined(separator: ", ")
        let valuesRow = "(" + queryValues + ")"
        q += valuesRow
        return TypedLoneInsertSQLQuery(for: table, query: query + q, parameters: parameters + queryParams)
    }
    
    mutating func ADDVALUES(_ values: repeat each V) {
        var q = ""
        if query.contains("VALUES (") {
            q += ", "
        } else {
            q += "VALUES "
        }
        
        var queryParams = [Encodable]()
        for v in repeat each values {
            queryParams.append(v)
        }
        
        
        let nextPIndex = parameterNumber() + 1
        let queryValues = queryParams.enumerated().map { i, _ in "$\(nextPIndex+i)"}.joined(separator: ", ")
        let valuesRow = "(" + queryValues + ")"
        
        q += valuesRow
        query = query + q
        parameters += queryParams
    }
}

public extension TypedInsertSQLQuery {
    
    func VALUES(_ values: String...) -> TypedSQLQuery<T> {
        TypedSQLQuery(for: table, query: query + " (\(values.map{"'\($0)'"}.joined(separator: ", ")))", parameters: parameters)
    }
    
    func RETURNING<U>(_ kp: KeyPath<T, Field<U>>) -> TypedSQLQuery<T> {
        return TypedSQLQuery(for: table, query: query + " RETURNING \(table[keyPath: kp].name)", parameters: parameters)
    }
}


@available(macOS 14.0.0, *)
public struct TypedLoneInsertSQLQuery<T: Table, each V: Encodable>: SQLQuery {
    let table: T
    public var query: String = ""
    public var parameters: [(any Encodable)?]
        
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}


public struct TypedInsertSQLQuery<T: Table>: SQLQuery {
    let table: T
    public var query: String = ""
    public var parameters: [(any Encodable)?]
        
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}

