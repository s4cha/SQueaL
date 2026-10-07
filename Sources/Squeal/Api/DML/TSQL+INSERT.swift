//
//  SQL+INSERT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public extension SQL {
    
    static func INSERT<T, each U:Encodable>(INTO table: T,
                   columns: repeat KeyPath<T, TableColumn<T, each U>>,
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
        
        let q = "INSERT INTO \(T.schema) (\(columnNames.joined(separator: ", "))) VALUES (\(queryValues))"
        return TypedInsertSQLQuery(for: table, query: q, parameters: queryParams)
    }
    
    static func INSERT<T, each U: Encodable, X: Sequence>(
        INTO table: T,
        columns: repeat KeyPath<T, TableColumn<T, each U>>,
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
        let q = "INSERT INTO \(T.schema) (\(columnNames.joined(separator: ", "))) VALUES \(valuesString)"
        return TypedInsertSQLQuery(for: table, query: q, parameters: newParams) // TODO
    }
    
    @available(macOS 14.0.0, *)
    static func INSERT<T, each U>(INTO table: T,
                   columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedLoneInsertSQLQuery<T, repeat each U> {
        
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        
        let q = "INSERT INTO \(T.schema) (\(columnNames.joined(separator: ", "))) "
        return TypedLoneInsertSQLQuery(for: table, query: q, parameters: []) // TODO
    }
    
    /// INSERT that supports a mix of plain Encodable values (bound as parameters) and
    /// raw SQL expressions (e.g. PostGIS `ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography`).
    ///
    /// Use `SQLExpr("...", args...)` (with `?` placeholders) or `RawSQL("...")` for expressions.
    /// Plain values (any Encodable) are automatically parameterized.
    static func INSERT<T, each C>(
        INTO table: T,
        columns: repeat KeyPath<T, TableColumn<T, each C>>,
        VALUES values: Any...
    ) -> TypedInsertSQLQuery<T> {
        
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        
        var allParams: [(any Encodable)?] = []
        var valueFragments: [String] = []
        var pIndex = 0
        
        func nextPlaceholder() -> String {
            pIndex += 1
            return "$\(pIndex)"
        }
        
        for v in values {
            if let expr = v as? SQLExpr {
                var frag = expr.sql
                for arg in expr.parameters {
                    let ph = nextPlaceholder()
                    if let qRange = frag.range(of: "?") {
                        frag.replaceSubrange(qRange, with: ph)
                    }
                    allParams.append(arg)
                }
                valueFragments.append(frag)
            } else if let raw = v as? RawSQL {
                valueFragments.append(raw.expression)
                // no additional parameters
            } else if let enc = v as? any Encodable {
                allParams.append(enc)
                valueFragments.append(nextPlaceholder())
            } else {
                // Fallback – treat unknowns as NULL (or could fatalError in debug)
                valueFragments.append("NULL")
            }
        }
        
        let q = "INSERT INTO \(T.schema) (\(columnNames.joined(separator: ", "))) VALUES (\(valueFragments.joined(separator: ", ")))"
        return TypedInsertSQLQuery(for: table, query: q, parameters: allParams)
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
    
    /// VALUES supporting a mix of plain values and raw SQL expressions (e.g. PostGIS).
    func VALUES(_ values: Any...) -> TypedLoneInsertSQLQuery {
        var q = ""
        if query.contains("VALUES (") {
            q += ", "
        } else {
            q += "VALUES "
        }
        
        var addedParams: [(any Encodable)?] = []
        var fragments: [String] = []
        var pIndex = parameterNumber()
        
        func nextPlaceholder() -> String {
            pIndex += 1
            return "$\(pIndex)"
        }
        
        for v in values {
            if let expr = v as? SQLExpr {
                var frag = expr.sql
                for arg in expr.parameters {
                    let ph = nextPlaceholder()
                    if let qRange = frag.range(of: "?") {
                        frag.replaceSubrange(qRange, with: ph)
                    }
                    addedParams.append(arg)
                }
                fragments.append(frag)
            } else if let raw = v as? RawSQL {
                fragments.append(raw.expression)
            } else if let enc = v as? any Encodable {
                addedParams.append(enc)
                fragments.append(nextPlaceholder())
            } else {
                fragments.append("NULL")
            }
        }
        
        let valuesRow = "(" + fragments.joined(separator: ", ") + ")"
        q += valuesRow
        return TypedLoneInsertSQLQuery(for: table, query: query + q, parameters: parameters + addedParams)
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
    
    /// ADDVALUES supporting a mix of plain values and raw SQL expressions (e.g. PostGIS).
    mutating func ADDVALUES(_ values: Any...) {
        var q = ""
        if query.contains("VALUES (") {
            q += ", "
        } else {
            q += "VALUES "
        }
        
        var addedParams: [(any Encodable)?] = []
        var fragments: [String] = []
        var pIndex = parameterNumber()
        
        func nextPlaceholder() -> String {
            pIndex += 1
            return "$\(pIndex)"
        }
        
        for v in values {
            if let expr = v as? SQLExpr {
                var frag = expr.sql
                for arg in expr.parameters {
                    let ph = nextPlaceholder()
                    if let qRange = frag.range(of: "?") {
                        frag.replaceSubrange(qRange, with: ph)
                    }
                    addedParams.append(arg)
                }
                fragments.append(frag)
            } else if let raw = v as? RawSQL {
                fragments.append(raw.expression)
            } else if let enc = v as? any Encodable {
                addedParams.append(enc)
                fragments.append(nextPlaceholder())
            } else {
                fragments.append("NULL")
            }
        }
        
        let valuesRow = "(" + fragments.joined(separator: ", ") + ")"
        q += valuesRow
        query = query + q
        parameters += addedParams
    }
}

public extension TypedInsertSQLQuery {
    
    func VALUES(_ values: String...) -> TypedSQLQuery<T, Void> {
        TypedSQLQuery(for: table, query: query + " (\(values.map{"'\($0)'"}.joined(separator: ", ")))", parameters: parameters)
    }
    
    func RETURNING<U>(_ kp: KeyPath<T, TableColumn<T, U>>) -> TypedSQLQuery<T, Void> {
        return TypedSQLQuery(for: table, query: query + " RETURNING \(table[keyPath: kp].name)", parameters: parameters)
    }

    func RETURNING<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSQLQuery<T, Void> {
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSQLQuery(for: table, query: query + " RETURNING \(columnNames.joined(separator: ", "))", parameters: parameters)
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

// MARK: - ON CONFLICT support

public struct OnConflictInsertQuery<T: Table>: SQLQuery {
    let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
    
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}

// Extend insert query types with ON CONFLICT entry points

public extension TypedInsertSQLQuery {
    
    func ON_CONFLICT<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>, DO: ConflictAction) -> OnConflictInsertQuery<T> {
        var names: [String] = []
        for kp in repeat each columns {
            names.append(table[keyPath: kp].name)
        }
        let target = names.isEmpty ? "" : " (\(names.joined(separator: ", ")))"
        return OnConflictInsertQuery(for: table, query: query + " ON CONFLICT\(target)" + " DO \(DO.rawValue)", parameters: parameters)
    }
    
    func ON_CONFLICT(DO: ConflictAction) -> OnConflictInsertQuery<T> {
        return OnConflictInsertQuery(for: table, query: query + " ON CONFLICT" + " DO \(DO.rawValue)", parameters: parameters)
    }
    
    func ON_CONFLICT(ON_CONSTRAINT name: String, DO: ConflictAction) -> OnConflictInsertQuery<T> {
        return OnConflictInsertQuery(for: table, query: query + " ON CONFLICT ON CONSTRAINT \(name)" + " DO \(DO.rawValue)", parameters: parameters)
    }
}

public enum ConflictAction: String{
    case NOTHING = "NOTHING"
}


@available(macOS 14.0.0, *)
public extension TypedLoneInsertSQLQuery {
    
    func ON_CONFLICT<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>, DO: ConflictAction) -> OnConflictInsertQuery<T> {
        var names: [String] = []
        for kp in repeat each columns {
            names.append(table[keyPath: kp].name)
        }
        let target = names.isEmpty ? "" : " (\(names.joined(separator: ", ")))"
        return OnConflictInsertQuery(for: table, query: query + " ON CONFLICT\(target)" + " DO \(DO.rawValue)", parameters: parameters)
    }
    
    func ON_CONFLICT(DO: ConflictAction) -> OnConflictInsertQuery<T> {
        return OnConflictInsertQuery(for: table, query: query + " ON CONFLICT" + " DO \(DO.rawValue)", parameters: parameters)
    }
    
    func ON_CONFLICT(ON_CONSTRAINT name: String, DO: ConflictAction) -> OnConflictInsertQuery<T> {
        return OnConflictInsertQuery(for: table, query: query + " ON CONFLICT ON CONSTRAINT \(name)" + "DO \(DO.rawValue)", parameters: parameters)
    }
}

public extension OnConflictInsertQuery {

    func RETURNING<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSQLQuery<T, Void> {
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSQLQuery(for: table, query: query + " RETURNING \(columnNames.joined(separator: ", "))", parameters: parameters)
    }
}
