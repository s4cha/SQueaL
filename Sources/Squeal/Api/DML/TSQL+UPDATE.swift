//
//  TSQL+UPDATE.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation

/// An `UPDATE … SET` waiting for its `WHERE` clause.
///
/// It isn't an ``SQLQuery``, so you can't run it, or pass it to `PostgresClient.query(_:)`,
/// until you add a `WHERE`. An `UPDATE` that would change every row doesn't compile:
///
/// ```swift
/// try await client.query(UPDATE(users, SET: (\.name, "Ada")))
/// // error: 'query(_:logger:file:line:)' is unavailable: Add a WHERE clause:
/// //        this UPDATE would change every row. …
///
/// try await client.query(UPDATE(users, SET: (\.name, "Ada")).WHERE(\.id == id))   // OK
/// ```
///
/// To update every row on purpose, say so with a condition that's always true:
/// `.WHERE(SQLExpr("true"))`.
public struct TypedUpdateSQLQuery<T: Table, Row>: TableSQLFragment, WHEREableQuery {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
        
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = normalizedParameters(parameters)
    }
}


public extension SQL {
    
    /// Starts an `UPDATE` that sets columns to values.
    ///
    /// Each value is bound as a parameter, and must have its column's type.
    ///
    /// The result isn't a query you can run until you add `WHERE`, so an `UPDATE` can't
    /// accidentally change every row. See ``TypedUpdateSQLQuery``.
    ///
    /// ```swift
    /// UPDATE(users, SET: (\.name, "Ada"), (\.age, 37)).WHERE(\.id == id)
    /// // UPDATE users SET name = $1, age = $2 WHERE id = $3
    /// ```
    ///
    /// > Warning: Without a `WHERE`, this updates every row in the table.
    static func UPDATE<T, each U: Encodable>(_ table: T, SET pairs: repeat (KeyPath<T, TableColumn<T, each U>>, (each U)?)) -> TypedUpdateSQLQuery<T, Void> {
        var q = "UPDATE \(T.schema) SET "
        let table = T()
        var parameters = [Encodable]()
        var setValues = [String]()
        var nextPIndex = 0
        for pair in repeat each pairs {
            nextPIndex = nextPIndex + 1
            setValues.append(table[keyPath: pair.0].name + " = $\(nextPIndex)")
            parameters.append(pair.1)
        }
        q += setValues.joined(separator: ", ")
        return TypedUpdateSQLQuery(for: table, query: q, parameters: parameters)
    }

    /// Starts an `UPDATE` whose values can mix plain values, ``SQLExpr``, ``NOW``, ``COALESCE``
    /// and subqueries, each checked against its column's type.
    ///
    /// ```swift
    /// UPDATE(posts, SET: (\.likes, SQLExpr("likes + ?", 1)), (\.updated_at, NOW())).WHERE(\.id == id)
    /// // UPDATE posts SET likes = likes + $1, updated_at = now() WHERE id = $2
    /// ```
    ///
    /// Every value, and every column's type, must be an ``SQLValue``. Write an enum value with its
    /// type (`TradeType.buy`) in such a row: `.buy` alone has no type to look it up in.
    @_disfavoredOverload
    static func UPDATE<T, each U: SQLValue, each V: SQLValue>(_ table: T, SET pairs: repeat (KeyPath<T, TableColumn<T, each U>>, each V)) -> TypedUpdateSQLQuery<T, Void> where repeat (each V).SQLType == (each U).SQLType {
        var columnNames = [String]()
        var values = [Any]()
        for pair in repeat each pairs {
            columnNames.append(table[keyPath: pair.0].name)
            values.append(pair.1)
        }
        return update(table, columnNames: columnNames, values: values)
    }

    /// Starts an `UPDATE` with values that aren't checked against their columns.
    @_disfavoredOverload
    @available(*, deprecated, message: "These values aren't checked against their columns. Use values of the columns' types. In a row with an expression, conform custom types to SQLValue (extension MyType: SQLValue {}), write raw SQL as SQLExpr instead of RawSQL, and give an SQLExpr stored in a variable its column's type (SQLExpr<MyType>(…)).")
    static func UPDATE<T, each U>(_ table: T, SET pairs: repeat (KeyPath<T, TableColumn<T, each U>>, Any)) -> TypedUpdateSQLQuery<T, Void> {
        var columnNames = [String]()
        var values = [Any]()
        for pair in repeat each pairs {
            columnNames.append(table[keyPath: pair.0].name)
            values.append(pair.1)
        }
        return update(table, columnNames: columnNames, values: values)
    }

    private static func update<T: Table>(_ table: T, columnNames: [String], values: [Any]) -> TypedUpdateSQLQuery<T, Void> {
        let (fragments, parameters) = renderSQLValues(values, parameterOffset: 0)
        let setValues = zip(columnNames, fragments).map { "\($0) = \($1)" }
        return TypedUpdateSQLQuery(for: table, query: "UPDATE \(T.schema) SET \(setValues.joined(separator: ", "))", parameters: parameters)
    }
}
