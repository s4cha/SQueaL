//
//  TSQL+SELECT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

/// A `SELECT` of key-path columns, waiting for its `FROM` clause.
///
/// `Row` is the selected columns' type: a single type for one column, or a tuple for several.
public struct TypedSelectSQLQuery<T: Table, Row>: TableSQLQuery, FROMableQuery {
    
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
        
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}

/// A `SELECT` of qualified columns or expressions, waiting for its `FROM` clause.
public struct SelectSQLQuery: SQLQuery, FROMableSQLQuery {
    
    public var query: String
    public var parameters: [(any Encodable)?]
        
    init(query: String, parameters: [(any Encodable)?]) {
        self.query = query
        self.parameters = parameters
    }
}


public extension TSQL {
    
    /// Selects every column: `SELECT *`.
    ///
    /// ```swift
    /// SQL.SELECT(*).FROM(users)   // SELECT * FROM users
    /// ```
    ///
    /// - Parameter function: Pass `*`.
    static func SELECT(_ function: (Int, Int) -> Int) -> TypedSelectSQLQuery<T, Void> {
        let table = T()
        return TypedSelectSQLQuery(for: table, query: "SELECT *", parameters: [])
    }
    
    /// Selects table-qualified columns, aggregates or raw expressions.
    ///
    /// ```swift
    /// SQL.SELECT(posts.author_id, COUNT(*), RawSQL("max(likes)")).FROM(posts)
    /// // SELECT posts.author_id, COUNT(*), max(likes) FROM posts
    /// ```
    static func SELECT<each Z: SelectField>(_ fields: repeat each Z) -> SelectSQLQuery {
        var fieldNames = [String]()
        for field in repeat each fields {
            fieldNames.append(field.toString())
        }
        return SelectSQLQuery(query: "SELECT \(fieldNames.joined(separator: ", "))", parameters: [])
    }
    
    /// Selects columns of `T`, given as key paths.
    ///
    /// The selected columns' types become the query's `Row` type, so the query can serve as a typed subquery.
    ///
    /// ```swift
    /// TSQL<UserTable>.SELECT(\.id, \.name).FROM(users)   // SELECT id, name FROM users
    /// ```
    static func SELECT<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSelectSQLQuery<T, (repeat each U)> {
        let table = T()
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT \(columnNames.joined(separator: ", "))", parameters: [])
    }
    
    /// Selects the distinct values of columns of `T`: `SELECT DISTINCT …`.
    static func SELECT_DISTINCT<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSelectSQLQuery<T, (repeat each U)> {
        let table = T()
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT DISTINCT \(columnNames.joined(separator: ", "))", parameters: [])
    }
    
    /// Selects columns of `T` renamed with `AS`.
    ///
    /// ```swift
    /// TSQL<UserTable>.SELECT((\.id, AS: "user_id")).FROM(users)
    /// // SELECT id AS user_id FROM users
    /// ```
    static func SELECT<each U>(_ aliases: repeat (KeyPath<T, TableColumn<T, each U>>, AS: String)) -> TypedSelectSQLQuery<T, (repeat each U)> {
        let table = T()
        var columnNames = [String]()
        for alias in repeat each aliases {
            columnNames.append(table[keyPath: alias.0].name + " AS \(alias.AS)")
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT \(columnNames.joined(separator: ", "))", parameters: [])
    }
    
    /// Selects the distinct values of columns of `T` renamed with `AS`.
    static func SELECT_DISTINCT<each U>(_ aliases: repeat (KeyPath<T, TableColumn<T, each U>>, AS: String)) -> TypedSelectSQLQuery<T, (repeat each U)> {
        let table = T()
        var columnNames = [String]()
        for alias in repeat each aliases {
            columnNames.append(table[keyPath: alias.0].name + " AS \(alias.AS)")
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT DISTINCT \(columnNames.joined(separator: ", "))", parameters: [])
    }
    


}

public extension SQL {
    
    /// Selects every column: `SELECT *`.
    ///
    /// ```swift
    /// SQL.SELECT(*).FROM(users)   // SELECT * FROM users
    /// ```
    ///
    /// - Parameter function: Pass `*`.
    static func SELECT(_ function: (Int, Int) -> Int) -> SelectSQLQuery {
        return SelectSQLQuery(query: "SELECT *", parameters: [])
    }
    
    /// Selects table-qualified columns, aggregates or raw expressions.
    ///
    /// ```swift
    /// SQL.SELECT(posts.author_id, COUNT(*), RawSQL("max(likes)")).FROM(posts)
    /// // SELECT posts.author_id, COUNT(*), max(likes) FROM posts
    /// ```
    static func SELECT<each Z: SelectField>(_ fields: repeat each Z) -> SelectSQLQuery {
        var fieldNames = [String]()
        for field in repeat each fields {
            fieldNames.append(field.toString())
        }
        return SelectSQLQuery(query: "SELECT \(fieldNames.joined(separator: ", "))", parameters: [])
    }
 
    /// Selects columns, given as key paths.
    ///
    /// The selected columns' types become the query's `Row` type, so the query can serve as a typed subquery.
    ///
    /// ```swift
    /// SQL.SELECT(\.id, \.name).FROM(users)   // SELECT id, name FROM users
    /// ```
    static func SELECT<T, each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSelectSQLQuery<T, (repeat each U)> {
        let table = T()
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT \(columnNames.joined(separator: ", "))", parameters: [])
    }
    
    /// Selects the distinct values of columns: `SELECT DISTINCT …`.
    ///
    /// ```swift
    /// SQL.SELECT_DISTINCT(\.age).FROM(users)   // SELECT DISTINCT age FROM users
    /// ```
    static func SELECT_DISTINCT<T, each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSelectSQLQuery<T, (repeat each U)> {
        let table = T()
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSelectSQLQuery(for: table, query: "SELECT DISTINCT \(columnNames.joined(separator: ", "))", parameters: [])
    }
     
    /// Selects columns renamed with `AS`.
    ///
    /// Spell out the table type in the first key path so the compiler can resolve it:
    ///
    /// ```swift
    /// SQL.SELECT((\UserTable.id, AS: "user_id"), (\UserTable.name, AS: "username")).FROM(users)
    /// // SELECT id AS user_id, name AS username FROM users
    /// ```
    static func SELECT<T, each U>(_ aliases: repeat (KeyPath<T, TableColumn<T, each U>>, AS: String)) -> SelectSQLQuery {
        let table = T()
        var columnNames = [String]()
        for alias in repeat each aliases {
            columnNames.append(table[keyPath: alias.0].name + " AS \(alias.AS)")
        }
        return SelectSQLQuery(query: "SELECT \(columnNames.joined(separator: ", "))", parameters: [])
    }
    
    /// Selects the distinct values of columns renamed with `AS`.
    static func SELECT_DISTINCT<T, each U>(_ aliases: repeat (KeyPath<T, TableColumn<T, each U>>, AS: String)) -> SelectSQLQuery {
        let table = T()
        var columnNames = [String]()
        for alias in repeat each aliases {
            columnNames.append(table[keyPath: alias.0].name + " AS \(alias.AS)")
        }
        return SelectSQLQuery(query: "SELECT DISTINCT \(columnNames.joined(separator: ", "))", parameters: [])
    }
}



/// An expression that can appear in a `SELECT` or `RETURNING` list.
///
/// Table-qualified columns (`users.name`), the aggregates ``COUNT``, ``SUM``, ``AVG``, ``MIN`` and ``MAX``, and ``RawSQL`` all conform.
public protocol SelectField {
    /// The expression's SQL text.
    func toString() -> String
}


/// The `COUNT` aggregate.
///
/// ```swift
/// COUNT(*)          // COUNT(*)
/// COUNT(\.id)       // COUNT(id)
/// COUNT(posts.id)   // COUNT(posts.id)
/// ```
public struct COUNT {
    /// The SQL text of the expression.
    public let string: String
    
    /// Counts rows: `COUNT(*)`.
    ///
    /// - Parameter function: Pass `*`.
    public init(_ function: (Int, Int) -> Int) {
        self.string =  "COUNT(*)"
    }
    
    /// Applies the aggregate to a table-qualified column, such as `posts.likes`.
    public init<T, Y>(_ column: TableColumn<T, Y>) {
        self.string = "COUNT(\(column.tableName).\(column.name))"
    }
    
    /// Applies the aggregate to a column given as a key path, such as `\.likes`.
    public init<T, Y>(_ column: KeyPath<T, TableColumn<T, Y>>) where T: Table {
        let table = T()
        self.string = "COUNT(\(table[keyPath: column].name))"
    }
}

extension TableColumn: SelectField {
    public func toString() -> String {
        return "\(tableName).\(name)"
    }
}


extension COUNT: SelectField {
    public func toString() -> String {
        return string
    }
}

/// A SQL expression inserted verbatim.
///
/// Use it in `SELECT` and `RETURNING` lists, as a value in `INSERT` and `UPDATE`, or as the `WHERE` clause of a partial-index conflict target:
///
/// ```swift
/// SQL.SELECT(users.id, RawSQL("upper(name) AS shout")).FROM(users)
/// // SELECT users.id, upper(name) AS shout FROM users
/// ```
///
/// > Warning: The expression isn't escaped or parameterized. Never build it from user input. Use ``SQLExpr`` when the expression needs values.
public struct RawSQL: SelectField {
    /// The SQL text.
    public let expression: String
    /// Creates an expression from SQL text.
    public init(_ expression: String) {
        self.expression = expression
    }
    public func toString() -> String {
        return expression
    }
}

/// A SQL expression with bound parameters, used as a value in `INSERT … VALUES` or `UPDATE … SET`.
///
/// Write `?` where each value goes. When the query is built, each `?` becomes the next
/// numbered placeholder (`$n`) and its value is bound as a parameter:
///
/// ```swift
/// SQL.UPDATE(posts, SET: (\.likes, SQLExpr("likes + ?", 1)))
/// // UPDATE posts SET likes = likes + $1
///
/// SQLExpr("ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography", lng, lat)
/// ```
public struct SQLExpr {
    /// The SQL text, with a `?` where each parameter goes.
    public let sql: String
    /// The values bound to the `?` placeholders, in order.
    public let parameters: [(any Encodable)?]
    
    /// Creates an expression whose `?` placeholders are bound, in order, to `parameters`.
    public init(_ sql: String, _ parameters: (any Encodable)?...) {
        self.sql = sql
        self.parameters = parameters
    }

    init(sql: String, parameters: [(any Encodable)?]) {
        self.sql = sql
        self.parameters = parameters
    }
}

/// The `SUM` aggregate: `SUM(posts.likes)`.
public struct SUM: SelectField {
    /// The SQL text of the expression.
    public let string: String
    
    /// Applies the aggregate to a table-qualified column, such as `posts.likes`.
    public init<T, Y>(_ column: TableColumn<T, Y>) {
        self.string = "SUM(\(column.tableName).\(column.name))"
    }
    
    /// Applies the aggregate to a column given as a key path, such as `\.likes`.
    public init<T, Y>(_ column: KeyPath<T, TableColumn<T, Y>>) where T: Table {
        let table = T()
        self.string = "SUM(\(table[keyPath: column].name))"
    }
    
    public func toString() -> String {
        return string
    }
}

/// The `AVG` aggregate: `AVG(users.age)`.
public struct AVG: SelectField {
    /// The SQL text of the expression.
    public let string: String
    
    /// Applies the aggregate to a table-qualified column, such as `posts.likes`.
    public init<T, Y>(_ column: TableColumn<T, Y>) {
        self.string = "AVG(\(column.tableName).\(column.name))"
    }
    
    /// Applies the aggregate to a column given as a key path, such as `\.likes`.
    public init<T, Y>(_ column: KeyPath<T, TableColumn<T, Y>>) where T: Table {
        let table = T()
        self.string = "AVG(\(table[keyPath: column].name))"
    }
    
    public func toString() -> String {
        return string
    }
}

/// The `MIN` aggregate: `MIN(users.age)`.
public struct MIN: SelectField {
    /// The SQL text of the expression.
    public let string: String
    
    /// Applies the aggregate to a table-qualified column, such as `posts.likes`.
    public init<T, Y>(_ column: TableColumn<T, Y>) {
        self.string = "MIN(\(column.tableName).\(column.name))"
    }
    
    /// Applies the aggregate to a column given as a key path, such as `\.likes`.
    public init<T, Y>(_ column: KeyPath<T, TableColumn<T, Y>>) where T: Table {
        let table = T()
        self.string = "MIN(\(table[keyPath: column].name))"
    }
    
    public func toString() -> String {
        return string
    }
}

/// The `MAX` aggregate: `MAX(users.age)`.
public struct MAX: SelectField {
    /// The SQL text of the expression.
    public let string: String
    
    /// Applies the aggregate to a table-qualified column, such as `posts.likes`.
    public init<T, Y>(_ column: TableColumn<T, Y>) {
        self.string = "MAX(\(column.tableName).\(column.name))"
    }
    
    /// Applies the aggregate to a column given as a key path, such as `\.likes`.
    public init<T, Y>(_ column: KeyPath<T, TableColumn<T, Y>>) where T: Table {
        let table = T()
        self.string = "MAX(\(table[keyPath: column].name))"
    }
    
    public func toString() -> String {
        return string
    }
}

