//
//  SQL+INSERT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public extension String {
    
    func INSERT<T, each U>(INTO table: T,
                   columns: repeat KeyPath<T, Field<each U>>,
                   VALUES values: repeat each U) -> TypedInsertSQLQuery<T> {
        
        let cols = "\((repeat table[keyPath: (each columns)].name))"
        let sanitizedCols = cols.replacingOccurrences(of: "\"", with: "")
        
        let vals = "\((repeat each values))"
        let sanitizedVals = vals.replacingOccurrences(of: "\"", with: "'")
        
        let q = "INSERT INTO \(table.tableName) \(sanitizedCols) VALUES \(sanitizedVals)"
        return TypedInsertSQLQuery(for: table, raw: q)
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
        return TypedInsertSQLQuery(for: table, raw: q)
    }
    
    
    @available(macOS 14.0.0, *)
    func INSERT<T, each U>(INTO table: T,
                   columns: repeat KeyPath<T, Field<each U>>) -> TypedLoneInsertSQLQuery<T, repeat each U> {
        
        let cols = "\((repeat table[keyPath: (each columns)].name))"
        let sanitizedCols = cols.replacingOccurrences(of: "\"", with: "")
        
//        let vals = "\((repeat each values))"
//        let sanitizedVals = vals.replacingOccurrences(of: "\"", with: "'")
        
        let q = "INSERT INTO \(table.tableName) \(sanitizedCols) "
        return TypedLoneInsertSQLQuery(for: table, raw: q)
    }
    
    func INSERT<T>(INTO table: T, columnNames: String..., VALUESARRAY: CustomStringConvertible?...) -> TypedInsertSQLQuery<T> {
        return TypedInsertSQLQuery(for: table, raw: "INSERT INTO \(table.tableName)"
                                   + " (\(columnNames.joined(separator: ", ")))"
                                   + " VALUES (\(VALUESARRAY.map {"'\($0!)'"}.joined(separator: ", ")))")
    }
        
    func INSERT<T, X>(INTO table: T, _ fields: Field<X>..., VALUES: CustomStringConvertible...) -> TypedInsertSQLQuery<T> {
        return TypedInsertSQLQuery(for: table, raw: "INSERT INTO \(table.tableName)"
                                   + " (\(fields.map { $0.name }.joined(separator: ", ")))"
                                   + " VALUES (\(VALUES.map {"'\($0)'"}.joined(separator: ", ")))")
    }
    
    func INSERT_INTO<T>(_ table: T, columns: String..., VALUES: CustomStringConvertible...) -> TypedInsertSQLQuery<T> {
        return TypedInsertSQLQuery(for: table, raw: "INSERT INTO \(table.tableName)"
                                   + " (\(columns.joined(separator: ", ")))"
                                   + " VALUES (\(VALUES.map {"'\($0)'"}.joined(separator: ", ")))")
    }
        
}

@available(macOS 14.0.0, *)
public extension TypedLoneInsertSQLQuery {
    func VALUES(_ values: repeat each V) -> TypedLoneInsertSQLQuery {
        var q = ""
        if raw.contains("VALUES (") {
            q += ", "
        } else {
            q += "VALUES "
        }
        
        let vals = "\((repeat each values))"
        let sanitizedVals = vals.replacingOccurrences(of: "\"", with: "'")
        
//        q += "("  + values.map {"'\($0)'"} .joined(separator: ", ") +  ")"
        q += sanitizedVals
        return TypedLoneInsertSQLQuery(for: table, raw: raw + q)
    }
    
    
    mutating func ADDVALUES(_ values: repeat each V) {
        var q = ""
        if raw.contains("VALUES (") {
            q += ", "
        } else {
            q += "VALUES "
        }
        
        let vals = "\((repeat each values))"
        let sanitizedVals = vals.replacingOccurrences(of: "\"", with: "'")
        
//        q += "("  + values.map {"'\($0)'"} .joined(separator: ", ") +  ")"
        q += sanitizedVals
        raw = raw + q
//        return TypedLoneInsertSQLQuery(for: table, raw: raw + q)
    }
}

public extension TypedInsertSQLQuery {
    
    func VALUES(_ values: String...) -> TypedSQLQuery<T> {
        TypedSQLQuery(schema: table, raw: raw + " (\(values.map{"'\($0)'"}.joined(separator: ", ")))")
    }
    
    func RETURNING<U>(_ kp: KeyPath<T, Field<U>>) -> TypedSQLQuery<T> {
        return TypedSQLQuery(schema: table, raw: raw + " RETURNING \(table[keyPath: kp].name)")
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
    public var raw: String
    

    init(for table: T, raw: String) {
        self.table = table
        self.raw = raw
    }
}



public struct TypedInsertSQLQuery<T: Table>: SQLQuery {
    
    let table: T
    public var raw: String
    

    init(for table: T, raw: String) {
        self.table = table
        self.raw = raw
    }
}

