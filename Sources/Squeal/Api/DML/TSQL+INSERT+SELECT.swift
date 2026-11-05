//
//  TSQL+INSERT+SELECT.swift
//  Squeal
//

import Foundation

public extension SQL {

    /// Inserts one row of values when a condition holds: `INSERT INTO table (a, b) SELECT $1, $2 WHERE …`.
    ///
    /// Add the condition with `WHERE`. Each value must have its column's type, and is bound as a
    /// parameter. Use it to insert only when related rows exist, or don't:
    ///
    /// ```swift
    /// SQL.INSERT(INTO: memberships, columns: \.team_id, \.user_id,
    ///            SELECT: teamId, userId)
    ///     .WHERE(EXISTS(SQL.SELECT(\.id).FROM(teams).WHERE(teams.id == teamId).AND(teams.owner_id == ownerId)))
    ///     .ON_CONFLICT(DO: .NOTHING)
    /// // INSERT INTO memberships (team_id, user_id) SELECT $1, $2
    /// //     WHERE EXISTS (SELECT id FROM teams WHERE teams.id = $3 AND teams.owner_id = $4)
    /// //     ON CONFLICT DO NOTHING
    /// ```
    ///
    /// Without a condition, it inserts the row like `VALUES` does.
    static func INSERT<T, each U: Encodable>(INTO table: T,
                                              columns: repeat KeyPath<T, TableColumn<T, each U>>,
                                              SELECT values: repeat each U) -> TypedInsertSelectSQLQuery<T> {
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        var parameters = [(any Encodable)?]()
        for value in repeat each values {
            parameters.append(value)
        }
        let placeholders = parameters.indices.map { "$\($0 + 1)" }.joined(separator: ", ")
        return TypedInsertSelectSQLQuery(for: table,
                                         query: "INSERT INTO \(T.schema) (\(columnNames.joined(separator: ", "))) SELECT \(placeholders)",
                                         parameters: parameters)
    }

    /// Inserts the rows a query returns: `INSERT INTO table (a, b) SELECT …`.
    ///
    /// The query must select the columns' types, in order:
    ///
    /// ```swift
    /// SQL.INSERT(INTO: archived_posts, columns: \.id, \.title,
    ///            SELECT: SQL.SELECT(\.id, \.title).FROM(posts).WHERE(\.likes < 10))
    /// // INSERT INTO archived_posts (id, title) SELECT id, title FROM posts WHERE likes < $1
    /// ```
    static func INSERT<T, each U, Q: TableSQLQuery>(INTO table: T,
                                                    columns: repeat KeyPath<T, TableColumn<T, each U>>,
                                                    SELECT query: Q) -> TypedInsertSQLQuery<T> where Q.Row == (repeat each U) {
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        // Nothing precedes the query, so its $n placeholders need no renumbering.
        return TypedInsertSQLQuery(for: table,
                                   query: "INSERT INTO \(T.schema) (\(columnNames.joined(separator: ", "))) \(query.query)",
                                   parameters: query.parameters)
    }
}

/// An `INSERT … SELECT` of values, optionally with a condition.
///
/// Next, you can add `WHERE`, then `AND` or `OR`, then `ON_CONFLICT` or `RETURNING`.
public struct TypedInsertSelectSQLQuery<T: Table>: SQLQuery {
    let table: T
    public var query: String
    public var parameters: [(any Encodable)?]

    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = normalizedParameters(parameters)
    }

    /// Inserts the values only when the condition holds: `WHERE condition`.
    ///
    /// The condition isn't tied to the inserted table: compare table-qualified columns, use
    /// ``EXISTS`` or ``NOT_EXISTS``, or an ``SQLExpr``.
    public func WHERE(_ condition: some SQLCondition) -> TypedInsertSelectWhereSQLQuery<T> {
        let (q, p) = appending("WHERE", condition, mainTable: T.self)
        return TypedInsertSelectWhereSQLQuery(for: table, query: q, parameters: p)
    }
}

/// An `INSERT … SELECT … WHERE` of values.
///
/// Next, you can add `AND`, `OR`, `ON_CONFLICT` or `RETURNING`.
public struct TypedInsertSelectWhereSQLQuery<T: Table>: SQLQuery {
    let table: T
    public var query: String
    public var parameters: [(any Encodable)?]

    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = normalizedParameters(parameters)
    }

    /// Adds a condition: `AND condition`.
    public func AND(_ condition: some SQLCondition) -> TypedInsertSelectWhereSQLQuery<T> {
        let (q, p) = appending("AND", condition, mainTable: T.self)
        return TypedInsertSelectWhereSQLQuery(for: table, query: q, parameters: p)
    }

    /// Adds an alternative condition: `OR condition`.
    public func OR(_ condition: some SQLCondition) -> TypedInsertSelectWhereSQLQuery<T> {
        let (q, p) = appending("OR", condition, mainTable: T.self)
        return TypedInsertSelectWhereSQLQuery(for: table, query: q, parameters: p)
    }
}

/// An `INSERT … SELECT` that can end with `ON_CONFLICT` or `RETURNING`, like an `INSERT … VALUES`.
public protocol InsertSelectQuery: SQLQuery {
    associatedtype T: Table
}

extension TypedInsertSelectSQLQuery: InsertSelectQuery {}
extension TypedInsertSelectWhereSQLQuery: InsertSelectQuery {}

public extension InsertSelectQuery {

    private var insert: TypedInsertSQLQuery<T> {
        TypedInsertSQLQuery(for: T(), query: query, parameters: parameters)
    }

    /// Handles conflicts on the given columns: `ON CONFLICT (a, b) DO NOTHING`.
    func ON_CONFLICT<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>, DO: ConflictAction) -> OnConflictInsertQuery<T> {
        insert.ON_CONFLICT(repeat each columns, DO: DO)
    }

    /// Handles a conflict on any constraint: `ON CONFLICT DO NOTHING`.
    func ON_CONFLICT(DO: ConflictAction) -> OnConflictInsertQuery<T> {
        insert.ON_CONFLICT(DO: DO)
    }

    /// Handles a conflict on a named constraint: `ON CONFLICT ON CONSTRAINT name DO NOTHING`.
    func ON_CONFLICT(ON_CONSTRAINT name: String, DO: ConflictAction) -> OnConflictInsertQuery<T> {
        insert.ON_CONFLICT(ON_CONSTRAINT: name, DO: DO)
    }

    /// Returns columns of the inserted rows: `RETURNING a, b, …`.
    func RETURNING<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSQLQuery<T, Void> {
        insert.RETURNING(repeat each columns)
    }

    /// Returns table-qualified columns, expressions or subqueries of the inserted rows.
    func RETURNING<each F: SelectField>(_ fields: repeat each F) -> TypedSQLQuery<T, Void> {
        insert.RETURNING(repeat each fields)
    }
}

// MARK: - SELECT of values

/// The table of a `SELECT` without `FROM`. It has no columns, so its conditions use
/// table-qualified columns, ``EXISTS``, ``NOT_EXISTS`` or ``SQLExpr``.
public struct NoTable: Table {
    public static let schema = ""
    public init() {}
}

public extension SQL {
    /// Selects a number, as in the common `EXISTS (SELECT 1 FROM …)`: `SELECT 1`.
    ///
    /// The number is written as text: an integer can't carry SQL. Follow it with `FROM`, or with
    /// `WHERE` to select without a table:
    ///
    /// ```swift
    /// EXISTS(SQL.SELECT(1).FROM(memberships).WHERE(memberships.user_id == userId))
    /// // EXISTS (SELECT 1 FROM memberships WHERE memberships.user_id = $1)
    /// ```
    static func SELECT(_ number: Int) -> TypedSelectNumberSQLQuery {
        return TypedSelectNumberSQLQuery(query: "SELECT \(number)", parameters: [])
    }

    /// Selects values without a table: `SELECT $1, $2`.
    ///
    /// Values are bound as parameters, except integers, which are written as text. The values'
    /// types become the query's `Row`. Add a condition with `WHERE`:
    ///
    /// ```swift
    /// SQL.SELECT(teamId, userId).WHERE(NOT_EXISTS(SQL.SELECT(1).FROM(memberships).WHERE(memberships.user_id == userId)))
    /// // SELECT $1, $2 WHERE NOT EXISTS (SELECT 1 FROM memberships WHERE memberships.user_id = $3)
    /// ```
    static func SELECT<each V: Encodable>(_ values: repeat each V) -> TypedValuesSelectSQLQuery<(repeat each V)> {
        var fields = [String]()
        var parameters = [(any Encodable)?]()
        for value in repeat each values {
            // An integer can't carry SQL, so it's safe to write as text.
            if let integer = value as? any BinaryInteger {
                fields.append("\(integer)")
            } else {
                parameters.append(value)
                fields.append("$\(parameters.count)")
            }
        }
        return TypedValuesSelectSQLQuery(query: "SELECT \(fields.joined(separator: ", "))", parameters: parameters)
    }
}

/// A `SELECT` of values, without a table. Next, you can add `WHERE`.
public struct TypedValuesSelectSQLQuery<Row>: TableSQLQuery, WHEREableQuery {
    public typealias T = NoTable
    public let table = NoTable()
    public var query: String
    public var parameters: [(any Encodable)?]

    init(query: String, parameters: [(any Encodable)?]) {
        self.query = query
        self.parameters = normalizedParameters(parameters)
    }
}

/// A `SELECT` of a number, such as `SELECT 1`. Next, you can add `FROM`, or `WHERE` to select
/// without a table.
public struct TypedSelectNumberSQLQuery: TableSQLQuery, WHEREableQuery {
    public typealias T = NoTable
    public typealias Row = Int
    public let table = NoTable()
    public var query: String
    public var parameters: [(any Encodable)?]

    init(query: String, parameters: [(any Encodable)?]) {
        self.query = query
        self.parameters = parameters
    }

    /// Adds the `FROM` clause. Key paths in later clauses resolve against `table`.
    ///
    /// ```swift
    /// SQL.SELECT(1).FROM(posts).WHERE(\.likes > 1000)   // SELECT 1 FROM posts WHERE likes > $1
    /// ```
    public func FROM<U: Table>(_ table: U) -> TypedFromSQLQuery<U, Int> {
        return TypedFromSQLQuery(for: table, query: query + " FROM \(U.schema)", parameters: parameters)
    }
}
