//
//  SQL+INSERT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public extension SQL {
    
    /// Inserts one row.
    ///
    /// Each value is bound as a parameter.
    ///
    /// > Warning: Value types and counts aren't checked against the columns yet: mismatches
    /// > compile and fail when Postgres runs the query.
    ///
    /// ```swift
    /// SQL.INSERT(INTO: users, columns: \.name, \.age, VALUES: "Ada", 36)
    /// // INSERT INTO users (name, age) VALUES ($1, $2)
    /// ```
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
    
    /// Inserts one row per element of a sequence.
    ///
    /// ```swift
    /// SQL.INSERT(INTO: users, columns: \.name, \.age,
    ///            addValuesFrom: newUsers, mapValues: { ($0.name, $0.age) })
    /// // INSERT INTO users (name, age) VALUES ($1, $2), ($3, $4), …
    /// ```
    ///
    /// - Parameters:
    ///   - table: The table to insert into.
    ///   - columns: The columns to fill.
    ///   - array: The elements to insert, one row each.
    ///   - mapValues: A closure that returns a row's values, in column order, for an element.
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
            nextPIndex += queryParams.count
            valueRows.append("(" + queryValues + ")")
        }
        
        let valuesString = valueRows.joined(separator: ", ")
        let q = "INSERT INTO \(T.schema) (\(columnNames.joined(separator: ", "))) VALUES \(valuesString)"
        return TypedInsertSQLQuery(for: table, query: q, parameters: newParams) // TODO
    }
    
    /// Starts an insert of several rows. Add each row with ``TypedLoneInsertSQLQuery/VALUES(_:)-(V)``
    /// or ``TypedLoneInsertSQLQuery/ADDVALUES(_:)-(V)``.
    ///
    /// ```swift
    /// SQL.INSERT(INTO: users, columns: \.name, \.age)
    ///     .VALUES("Ada", 36)
    ///     .VALUES("Grace", 45)
    /// // INSERT INTO users (name, age) VALUES ($1, $2), ($3, $4)
    /// ```
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
    
    /// Inserts one row whose values can mix plain values, SQL expressions and subqueries.
    ///
    /// - Plain values are bound as parameters.
    /// - ``SQLExpr`` values bind their arguments through `?` placeholders.
    /// - ``RawSQL`` values are inserted verbatim.
    /// - Queries are inserted as parenthesized subqueries, with their parameters renumbered.
    ///
    /// ```swift
    /// SQL.INSERT(INTO: posts, columns: \.id, \.title, \.published_at,
    ///            VALUES: RawSQL("gen_random_uuid()"), SQLExpr("trim(?)", title), RawSQL("now()"))
    /// // INSERT INTO posts (id, title, published_at) VALUES (gen_random_uuid(), trim($1), now())
    /// ```
    static func INSERT<T, each C>(
        INTO table: T,
        columns: repeat KeyPath<T, TableColumn<T, each C>>,
        VALUES values: Any...
    ) -> TypedInsertSQLQuery<T> {
        
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        
        let (valueFragments, allParams) = renderSQLValues(values, parameterOffset: 0)
        
        let q = "INSERT INTO \(T.schema) (\(columnNames.joined(separator: ", "))) VALUES (\(valueFragments.joined(separator: ", ")))"
        return TypedInsertSQLQuery(for: table, query: q, parameters: allParams)
    }
}

@available(macOS 14.0.0, *)
public extension TypedLoneInsertSQLQuery {
    
    /// Adds a row of values. Chain several calls to insert several rows.
    ///
    /// ```swift
    /// SQL.INSERT(INTO: users, columns: \.name, \.age)
    ///     .VALUES("Ada", 36)
    ///     .VALUES("Grace", 45)
    /// // INSERT INTO users (name, age) VALUES ($1, $2), ($3, $4)
    /// ```
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
    
    /// Adds a row whose values can mix plain values, ``SQLExpr``, ``RawSQL`` and subqueries.
    func VALUES(_ values: Any...) -> TypedLoneInsertSQLQuery {
        var q = ""
        if query.contains("VALUES (") {
            q += ", "
        } else {
            q += "VALUES "
        }
        
        let (fragments, addedParams) = renderSQLValues(values, parameterOffset: parameterNumber())
        
        let valuesRow = "(" + fragments.joined(separator: ", ") + ")"
        q += valuesRow
        return TypedLoneInsertSQLQuery(for: table, query: query + q, parameters: parameters + addedParams)
    }
    
    /// Adds a row of values in place, which is convenient in a loop.
    ///
    /// ```swift
    /// var insert = SQL.INSERT(INTO: users, columns: \.name, \.age)
    /// for user in newUsers {
    ///     insert.ADDVALUES(user.name, user.age)
    /// }
    /// ```
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
    
    /// Adds a row in place. Its values can mix plain values, ``SQLExpr``, ``RawSQL`` and subqueries.
    mutating func ADDVALUES(_ values: Any...) {
        var q = ""
        if query.contains("VALUES (") {
            q += ", "
        } else {
            q += "VALUES "
        }
        
        let (fragments, addedParams) = renderSQLValues(values, parameterOffset: parameterNumber())
        
        let valuesRow = "(" + fragments.joined(separator: ", ") + ")"
        q += valuesRow
        query = query + q
        parameters += addedParams
    }
}

public extension TypedInsertSQLQuery {

    /// RETURNING mixing table columns (`table.column`) and `RawSQL` expressions.
    func RETURNING<each F: SelectField>(_ fields: repeat each F) -> TypedSQLQuery<T, Void> {
        return TypedSQLQuery(for: table, query: query + returningClause(repeat each fields), parameters: parameters)
    }
    
    /// Appends a parenthesized list of single-quoted strings.
    ///
    /// > Warning: The strings are inlined without escaping or parameters. Prefer the `VALUES:` argument of `INSERT`, which binds every value.
    func VALUES(_ values: String...) -> TypedSQLQuery<T, Void> {
        TypedSQLQuery(for: table, query: query + " (\(values.map{"'\($0)'"}.joined(separator: ", ")))", parameters: parameters)
    }
    
    /// Returns a column of the inserted row: `RETURNING column`.
    func RETURNING<U>(_ kp: KeyPath<T, TableColumn<T, U>>) -> TypedSQLQuery<T, Void> {
        return TypedSQLQuery(for: table, query: query + " RETURNING \(table[keyPath: kp].name)", parameters: parameters)
    }

    /// Returns columns of the inserted rows: `RETURNING a, b, …`.
    func RETURNING<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSQLQuery<T, Void> {
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSQLQuery(for: table, query: query + " RETURNING \(columnNames.joined(separator: ", "))", parameters: parameters)
    }
}


/// An `INSERT` that receives its rows one at a time through `VALUES` or `ADDVALUES`.
///
/// Next, you can add more rows or `ON_CONFLICT`.
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


/// An `INSERT` with its values.
///
/// Next, you can add `ON_CONFLICT` or `RETURNING`.
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

/// An `INSERT … ON CONFLICT` query. Next, you can add `RETURNING`.
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
    
    /// Handles conflicts on the given columns: `ON CONFLICT (a, b) DO NOTHING`.
    ///
    /// ```swift
    /// .ON_CONFLICT(\.email, DO: .NOTHING)
    /// ```
    func ON_CONFLICT<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>, DO: ConflictAction) -> OnConflictInsertQuery<T> {
        var names: [String] = []
        for kp in repeat each columns {
            names.append(table[keyPath: kp].name)
        }
        let target = names.isEmpty ? "" : " (\(names.joined(separator: ", ")))"
        return OnConflictInsertQuery(for: table, query: query + " ON CONFLICT\(target)" + " DO \(DO.rawValue)", parameters: parameters)
    }
    
    /// Handles a conflict on any constraint: `ON CONFLICT DO NOTHING`.
    func ON_CONFLICT(DO: ConflictAction) -> OnConflictInsertQuery<T> {
        return OnConflictInsertQuery(for: table, query: query + " ON CONFLICT" + " DO \(DO.rawValue)", parameters: parameters)
    }
    
    /// Handles conflicts on a partial unique index: `ON CONFLICT (a) WHERE predicate DO NOTHING`.
    ///
    /// ```swift
    /// .ON_CONFLICT(\.email, WHERE: RawSQL("email IS NOT NULL"), DO: .NOTHING)
    /// ```
    func ON_CONFLICT<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>, WHERE predicate: RawSQL, DO: ConflictAction) -> OnConflictInsertQuery<T> {
        var names: [String] = []
        for kp in repeat each columns {
            names.append(table[keyPath: kp].name)
        }
        return OnConflictInsertQuery(for: table, query: query + " ON CONFLICT (\(names.joined(separator: ", "))) WHERE \(predicate.expression) DO \(DO.rawValue)", parameters: parameters)
    }
    
    /// Handles a conflict on a named constraint: `ON CONFLICT ON CONSTRAINT name DO NOTHING`.
    func ON_CONFLICT(ON_CONSTRAINT name: String, DO: ConflictAction) -> OnConflictInsertQuery<T> {
        return OnConflictInsertQuery(for: table, query: query + " ON CONFLICT ON CONSTRAINT \(name)" + " DO \(DO.rawValue)", parameters: parameters)
    }
}

/// What Postgres does when an insert conflicts with an existing row.
public enum ConflictAction: String{
    /// Skips the conflicting row: `DO NOTHING`.
    case NOTHING = "NOTHING"
}


@available(macOS 14.0.0, *)
public extension TypedLoneInsertSQLQuery {
    
    /// Handles conflicts on the given columns: `ON CONFLICT (a, b) DO NOTHING`.
    ///
    /// ```swift
    /// .ON_CONFLICT(\.email, DO: .NOTHING)
    /// ```
    func ON_CONFLICT<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>, DO: ConflictAction) -> OnConflictInsertQuery<T> {
        var names: [String] = []
        for kp in repeat each columns {
            names.append(table[keyPath: kp].name)
        }
        let target = names.isEmpty ? "" : " (\(names.joined(separator: ", ")))"
        return OnConflictInsertQuery(for: table, query: query + " ON CONFLICT\(target)" + " DO \(DO.rawValue)", parameters: parameters)
    }
    
    /// Handles a conflict on any constraint: `ON CONFLICT DO NOTHING`.
    func ON_CONFLICT(DO: ConflictAction) -> OnConflictInsertQuery<T> {
        return OnConflictInsertQuery(for: table, query: query + " ON CONFLICT" + " DO \(DO.rawValue)", parameters: parameters)
    }
    
    /// Handles conflicts on a partial unique index: `ON CONFLICT (a) WHERE predicate DO NOTHING`.
    ///
    /// ```swift
    /// .ON_CONFLICT(\.email, WHERE: RawSQL("email IS NOT NULL"), DO: .NOTHING)
    /// ```
    func ON_CONFLICT<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>, WHERE predicate: RawSQL, DO: ConflictAction) -> OnConflictInsertQuery<T> {
        var names: [String] = []
        for kp in repeat each columns {
            names.append(table[keyPath: kp].name)
        }
        return OnConflictInsertQuery(for: table, query: query + " ON CONFLICT (\(names.joined(separator: ", "))) WHERE \(predicate.expression) DO \(DO.rawValue)", parameters: parameters)
    }
    
    /// Handles a conflict on a named constraint: `ON CONFLICT ON CONSTRAINT name DO NOTHING`.
    func ON_CONFLICT(ON_CONSTRAINT name: String, DO: ConflictAction) -> OnConflictInsertQuery<T> {
        return OnConflictInsertQuery(for: table, query: query + " ON CONFLICT ON CONSTRAINT \(name)" + " DO \(DO.rawValue)", parameters: parameters)
    }
}

public extension OnConflictInsertQuery {

    /// RETURNING mixing table columns (`table.column`) and `RawSQL` expressions.
    func RETURNING<each F: SelectField>(_ fields: repeat each F) -> TypedSQLQuery<T, Void> {
        return TypedSQLQuery(for: table, query: query + returningClause(repeat each fields), parameters: parameters)
    }

    /// Returns columns of the inserted rows: `RETURNING a, b, …`.
    func RETURNING<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSQLQuery<T, Void> {
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSQLQuery(for: table, query: query + " RETURNING \(columnNames.joined(separator: ", "))", parameters: parameters)
    }
}
