//
//  SQL+INSERT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public extension String {
    
    
    //Waiting for Swift 6 to cleanly turn parameter pack into nice array of Encodables.
    func INSERT<T, each U:Encodable>(INTO table: T,
                   columns: repeat KeyPath<T, Field<each U>>,
                   VALUES values: repeat each U) -> TypedInsertSQLQuery<T> {
        
        let cols = "\((repeat table[keyPath: (each columns)].name))"
        let sanitizedCols = cols.replacingOccurrences(of: "\"", with: "")
        
//        let toto = [(repeat each values)]
//        print(toto)
//        
        let vals = "\((repeat each values))"
        
        
        let encoder = JSONEncoder()
//        let jsonData = repeat encoder.encode(each values)
            
        // Convert the JSON data to a String
//        if let jsonString = String(data: jsonData, encoding: .utf8)
            
        
//        let vtypes = "\((repeat each values).dynamicType)"
//        print(vals)
//        
//        let test = vals.substring(from: 1)
//        print(test)
//        let sanitizedVals = vals.replacingOccurrences(of: "\"", with: "'")
        let trimmedString = vals.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
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
            }
//            
            else {
                print(component)
                // Assuming the component is a string, remove the double quotes
                let trimmedComponent = component.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                parameters.append(trimmedComponent)
            }
        }
        print(parameters)
        
        
        let params = components.enumerated().map { i, _ in "$\(i+1)"}.joined(separator: ", ")
        
        
        // This is a nice workaround to turn parameter pack tuple into and array (https://gist.github.com/JensAyton/586f707722bb0b9715eba5bfb4a10c99)
//        var descriptions: [String] = []
//        func accumulate(_ string: String) {
//            descriptions.append(string)
//        }
//        (repeat accumulate(String(describing: each values)))
//        print(descriptions)
            
        
        let q = "INSERT INTO \(table.tableName) \(sanitizedCols) VALUES (\(params))"
        return TypedInsertSQLQuery(for: table, query: q, parameters: parameters)
    }
    
    func INSERT<T, each U, X: Sequence>(INTO table: T,
                   columns: repeat KeyPath<T, Field<each U>>,
                           addValuesFrom array: X,
                                           mapValues: (X.Element) -> String) -> TypedInsertSQLQuery<T> {
        
        let cols = "\((repeat table[keyPath: (each columns)].name))"
        let sanitizedCols = cols.replacingOccurrences(of: "\"", with: "")
        
        let values = array.map { mapValues($0) }
        values.joined(separator: ", ")
        
        
//        let vals = "\((repeat each values))"
//        let sanitizedVals = vals.replacingOccurrences(of: "\"", with: "'")
        
        
        let q = "INSERT INTO \(table.tableName) \(sanitizedCols) VALUES \(values)"
        return TypedInsertSQLQuery(for: table, query: q, parameters: []) // TODO
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
        print(newParameters)
        
        var paramNumber = parameterNumber()
        
        
        let params = components.map { _ in
            paramNumber += 1
            return "$\(paramNumber)"
        }.joined(separator: ", ")
        q += "("
        q += params
        q += ")"
        
        let sanitizedVals = vals.replacingOccurrences(of: "\"", with: "'")
        
//        q += "("  + values.map {"'\($0)'"} .joined(separator: ", ") +  ")"
//        q += sanitizedVals
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
        let sanitizedVals = vals.replacingOccurrences(of: "\"", with: "'")
        
//        q += "("  + values.map {"'\($0)'"} .joined(separator: ", ") +  ")"
        q += sanitizedVals
        query = query + q
//        return TypedLoneInsertSQLQuery(for: table, raw: raw + q)
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
////    func SELECT<T>(_ v: SQLSelectValue, FROM table: T) -> TypedFromSQLQuery<T> {
////        return TypedSQLQuery(for: table).SELECT(v).FROM(table)
////    }
////    
////    func SELECT<T, X>(_ keypath:  KeyPath<T, Field<X>>, FROM table: T) -> TypedFromSQLQuery<T> {
////        return TypedSQLQuery(for: table).SELECT(keypath).FROM(table)
////    }
////    
////    func SELECT<X, Y, T>(_ keypath1:  KeyPath<T, Field<X>>, _ keypath2:  KeyPath<T, Field<Y>>, FROM table: T) -> TypedFromSQLQuery<T> {
////        return TypedSelectSQLQuery(for: table, raw: "SELECT" + " " + table[keyPath: keypath1].name + ", " + table[keyPath: keypath1].name)
////            .FROM(table)
////    }
//
//}

//INSERT INTO table_name (column1, column2, column3, ...)
//VALUES (value1, value2, value3, ...);


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

