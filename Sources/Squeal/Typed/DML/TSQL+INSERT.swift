//
//  SQL+INSERT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


func parse(string: String) -> (String, [(any Encodable)?]) {
    let trimmedString = string.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
    let components = trimmedString.components(separatedBy: ", ")
    var parameters = [(any Encodable)?]()
    components.forEach { component in
        if component == "nil" {
            parameters.append(nil)
        }
        else if let int = Int(component) {
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
    let values = components.enumerated().map { i, _ in "$\(i+1)"}.joined(separator: ", ") // TODO remove from here and use next param
    
    return (values, parameters)
}

public extension String {
    
    
    //Waiting for Swift 6 to cleanly turn parameter pack into nice array of Encodables.
    func INSERT<T, each U:Encodable>(INTO table: T,
                   columns: repeat KeyPath<T, Field<each U>>,
                   VALUES values: repeat each U) -> TypedInsertSQLQuery<T> {
        
        let cols = "\((repeat table[keyPath: (each columns)].name))"
        let sanitizedCols = cols.replacingOccurrences(of: "\"", with: "")
        let vals = "\((repeat each values))"
        let (values, parameters) = parse(string: vals)
        let q = "INSERT INTO \(table.tableName) \(sanitizedCols) VALUES (\(values))"
        return TypedInsertSQLQuery(for: table, query: q, parameters: parameters)
    }
    
    func INSERT<T, each U, X: Sequence>(INTO table: T,
                   columns: repeat KeyPath<T, Field<each U>>,
                           addValuesFrom array: X,
                                           mapValues: (X.Element) -> (repeat each U)) -> TypedInsertSQLQuery<T> {
        
        let cols = "\((repeat table[keyPath: (each columns)].name))"
        let sanitizedCols = cols.replacingOccurrences(of: "\"", with: "")
        let vals = array.map { p in
            return mapValues(p)
        }.map {
            "\($0)".replacingOccurrences(of: "\"", with: "'")
        }.joined(separator: ", ")
        
        let (values, parameters) = parse(string: vals)
        
        let q = "INSERT INTO \(table.tableName) \(sanitizedCols) VALUES \(values)"
        return TypedInsertSQLQuery(for: table, query: q, parameters: parameters) // TODO
    }
    
    
    @available(macOS 14.0.0, *)
    func INSERT<T, each U>(INTO table: T,
                   columns: repeat KeyPath<T, Field<each U>>) -> TypedLoneInsertSQLQuery<T, repeat each U> {
        
        let cols = "\((repeat table[keyPath: (each columns)].name))"
        let sanitizedCols = cols.replacingOccurrences(of: "\"", with: "")
        let q = "INSERT INTO \(table.tableName) \(sanitizedCols) "
        return TypedLoneInsertSQLQuery(for: table, query: q, parameters: []) // TODO
    }
    
    func INSERT<T>(INTO table: T, columnNames: String..., VALUESARRAY: CustomStringConvertible?...) -> TypedInsertSQLQuery<T> {
        return TypedInsertSQLQuery(for: table, query: "INSERT INTO \(table.tableName)"
                                   + " (\(columnNames.joined(separator: ", ")))"
                                   + " VALUES (\(VALUESARRAY.map {"'\($0!)'"}.joined(separator: ", ")))", parameters: []) // TODO
    }
        
    func INSERT<T, X>(INTO table: T, _ fields: Field<X>..., VALUES: CustomStringConvertible...) -> TypedInsertSQLQuery<T> {
        return TypedInsertSQLQuery(for: table, query: "INSERT INTO \(table.tableName)"
                                   + " (\(fields.map { $0.name }.joined(separator: ", ")))"
                                   + " VALUES (\(VALUES.map {"'\($0)'"}.joined(separator: ", ")))", parameters: []) // TODO
    }
    
    func INSERT_INTO<T>(_ table: T, columns: String..., VALUES: CustomStringConvertible...) -> TypedInsertSQLQuery<T> {
        return TypedInsertSQLQuery(for: table, query: "INSERT INTO \(table.tableName)"
                                   + " (\(columns.joined(separator: ", ")))"
                                   + " VALUES (\(VALUES.map {"'\($0)'"}.joined(separator: ", ")))", parameters: []) // TODO
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
        let vals = "\((repeat each values))"
        let trimmedString = vals.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
        let components = trimmedString.components(separatedBy: ", ")
        var newParameters = [(any Encodable)?]()
        components.forEach { component in
            if let intValue = Int(component) {
                newParameters.append(intValue)
            } else {
                print(component)
                // Assuming the component is a string, remove the double quotes
                let trimmedComponent = component.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                newParameters.append(trimmedComponent)
            }
        }
        var paramNumber = parameterNumber()
        let params = components.map { _ in
            paramNumber += 1
            return "$\(paramNumber)"
        }.joined(separator: ", ")
        q += "("
        q += params
        q += ")"
        return TypedLoneInsertSQLQuery(for: table, query: query + q, parameters: parameters + newParameters)
    }
    
    
    mutating func ADDVALUES(_ values: repeat each V) {
        var q = ""
        if query.contains("VALUES (") {
            q += ", "
        } else {
            q += "VALUES "
        }
        
        let vals = "\((repeat each values))"
        let (values, params) = parse(string: vals)
        print("values", values)
        print("params", params)
//        let sanitizedVals = vals.replacingOccurrences(of: "\"", with: "'")
        let valuesRow = "(" + values + ")"
        q += valuesRow
        query = query + q
        parameters += params
        print("query", query)
        print("parameters", parameters)
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

