//
//  SQL+INSERT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


func parse(string: String) -> [(any Encodable)?] {
    let trimmedString = string.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
    let components = trimmedString.components(separatedBy: ", ")
    var parameters = [(any Encodable)?]()
    components.forEach { c in
        var component = c
        if component == "nil" {
            parameters.append(nil)
            return
        }
    
        if component.hasPrefix("Optional(") {
            // Remove the leading "Optional("
                let startIndex = component.index(component.startIndex, offsetBy: "Optional(".count)
                var endIndex = component.endIndex
    
                // Assuming the string ends with ")", adjust if necessary based on your use case
                if component.hasSuffix(")") {
                    endIndex = component.index(component.endIndex, offsetBy: -1)
                }
    
                // Extract the string between "Optional(" and the corresponding ")"
                let strippedString = String(component[startIndex..<endIndex])
            component = strippedString
        }
    
        if let int = Int(component) {
            parameters.append(int)
        }  else if let double = Double(component) {
            parameters.append(double)
        }
        else if let bool = Bool(component) {
            parameters.append(bool)
        } else if let uuid = UUID(uuidString: component) {
            parameters.append(uuid)
        }  else {
            // Assuming the component is a string, remove the double quotes
            let trimmedComponent = component.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            parameters.append(trimmedComponent)
        }
    }
    return parameters
}

public extension SQL {
    
    
    // Waiting for Swift 6 to cleanly turn parameter pack into nice array of Encodables.
    // This is subpar at the moment because types are erased inside a String
    @available(*, deprecated, message: "Use at your own risk")
    static func INSERT<T, each U:Encodable>(INTO table: T,
                   columns: repeat KeyPath<T, Field<each U>>,
                   VALUES values: repeat each U) -> TypedInsertSQLQuery<T> {
        
        let cols = "\((repeat table[keyPath: (each columns)].name))"
        var sanitizedCols = cols.replacingOccurrences(of: "\"", with: "")
        if sanitizedCols.first != "(" {
            sanitizedCols = "(\(sanitizedCols))"
        }
            
        let vals = "\((repeat each values))"
        let queryParams = parse(string: vals)
        let queryValues = queryParams.enumerated().map { i, _ in "$\(i+1)"}.joined(separator: ", ")
        print(queryParams)
        print(queryValues)
        let q = "INSERT INTO \(table.tableName) \(sanitizedCols) VALUES (\(queryValues))"
        return TypedInsertSQLQuery(for: table, query: q, parameters: queryParams)
    }
    
    static func INSERT<T, each U, X: Sequence>(INTO table: T,
                   columns: repeat KeyPath<T, Field<each U>>,
                           addValuesFrom array: X,
                                           mapValues: (X.Element) -> (repeat each U)) -> TypedInsertSQLQuery<T> {
        
        let cols = "\((repeat table[keyPath: (each columns)].name))"
        let sanitizedCols = cols.replacingOccurrences(of: "\"", with: "")
        var newParams = [(any Encodable)?]()
        var valueRows = [String]()
        var nextPIndex = 1
        for x in array {
            let tuple = mapValues(x)
            let tupleString = "\(tuple)"
            let queryParams = parse(string: tupleString)
            newParams += queryParams
            let queryValues = queryParams.enumerated().map { i, _ in "$\(nextPIndex + i)"}.joined(separator: ", ")
            print(queryValues)
            nextPIndex += queryParams.count
            valueRows.append("(" + queryValues + ")")
        }
        
        let valuesString = valueRows.joined(separator: ", ")
        let q = "INSERT INTO \(table.tableName) \(sanitizedCols) VALUES \(valuesString)"
        return TypedInsertSQLQuery(for: table, query: q, parameters: newParams) // TODO
    }
    
    @available(macOS 14.0.0, *)
    static func INSERT<T, each U>(INTO table: T,
                   columns: repeat KeyPath<T, Field<each U>>) -> TypedLoneInsertSQLQuery<T, repeat each U> {
        
        let cols = "\((repeat table[keyPath: (each columns)].name))"
        let sanitizedCols = cols.replacingOccurrences(of: "\"", with: "")
        let q = "INSERT INTO \(table.tableName) \(sanitizedCols) "
        return TypedLoneInsertSQLQuery(for: table, query: q, parameters: []) // TODO
    }
}

@available(macOS 14.0.0, *)
public extension TypedLoneInsertSQLQuery {
    
    @available(*, deprecated, message: "Use at your own risk")
    func VALUES(_ values: repeat each V) -> TypedLoneInsertSQLQuery {
        var q = ""
        if query.contains("VALUES (") {
            q += ", "
        } else {
            q += "VALUES "
        }
        let vals = "\((repeat each values))"
        let queryParams = parse(string: vals)
        let nextPIndex = parameterNumber() + 1
        let queryValues = queryParams.enumerated().map { i, _ in "$\(nextPIndex+i)"}.joined(separator: ", ")
        let valuesRow = "(" + queryValues + ")"
        q += valuesRow
        return TypedLoneInsertSQLQuery(for: table, query: query + q, parameters: parameters + queryParams)
    }
    
    @available(*, deprecated, message: "Use at your own risk")
    mutating func ADDVALUES(_ values: repeat each V) {
        var q = ""
        if query.contains("VALUES (") {
            q += ", "
        } else {
            q += "VALUES "
        }
        let vals = "\((repeat each values))"
        let queryParams = parse(string: vals)
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
public struct TypedLoneInsertSQLQuery<T: Table, each V>: SQLQuery {
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

