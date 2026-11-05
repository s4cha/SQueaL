//
//  INSERT_UPDATE_DELETE.swift
//  Squeal
//

// `INSERT`, `UPDATE` and `DELETE` without the `SQL.` prefix, like `SELECT`:
//
//     UPDATE(posts, SET: (\.title, "Hello")).WHERE(\.id == id)
//
// Each one is the same as its `SQL.` twin.

// MARK: - INSERT

/// Inserts one row: `INSERT INTO table (a, b) VALUES ($1, $2)`. Same as `SQL.INSERT(INTO:columns:VALUES:)`.
///
/// Each value must have its column's type, and is bound as a parameter.
public func INSERT<T, each U: Encodable>(INTO table: T,
                                         columns: repeat KeyPath<T, TableColumn<T, each U>>,
                                         VALUES values: repeat each U) -> TypedInsertSQLQuery<T> {
    return SQL.INSERT(INTO: table, columns: repeat each columns, VALUES: repeat each values)
}

/// Inserts one row whose values can mix plain values, ``SQLExpr``, ``NOW``, ``COALESCE`` and
/// subqueries, each checked against its column's type. Same as `SQL.INSERT(INTO:columns:VALUES:)`.
@_disfavoredOverload
public func INSERT<T, each C: SQLValue, each V: SQLValue>(INTO table: T,
                                                          columns: repeat KeyPath<T, TableColumn<T, each C>>,
                                                          VALUES values: repeat each V) -> TypedInsertSQLQuery<T> where repeat (each V).SQLType == (each C).SQLType {
    return SQL.INSERT(INTO: table, columns: repeat each columns, VALUES: repeat each values)
}

/// Inserts one row of values that aren't checked against their columns.
@_disfavoredOverload
@available(*, deprecated, message: "These values aren't checked against their columns. Use values of the columns' types. In a row with an expression, conform custom types to SQLValue (extension MyType: SQLValue {}), write raw SQL as SQLExpr instead of RawSQL, and give an SQLExpr stored in a variable its column's type (SQLExpr<MyType>(…)).")
public func INSERT<T, each C>(INTO table: T,
                              columns: repeat KeyPath<T, TableColumn<T, each C>>,
                              VALUES values: Any...) -> TypedInsertSQLQuery<T> {
    var columnNames = [String]()
    for column in repeat each columns {
        columnNames.append(table[keyPath: column].name)
    }
    return insertUntyped(INTO: table, columnNames: columnNames, values: values)
}

/// Inserts one row per element of a sequence. Same as `SQL.INSERT(INTO:columns:addValuesFrom:mapValues:)`.
public func INSERT<T, each U: Encodable, X: Sequence>(INTO table: T,
                                                      columns: repeat KeyPath<T, TableColumn<T, each U>>,
                                                      addValuesFrom array: X,
                                                      mapValues: (X.Element) -> (repeat each U)) -> TypedInsertSQLQuery<T> {
    return SQL.INSERT(INTO: table, columns: repeat each columns, addValuesFrom: array, mapValues: mapValues)
}

/// Starts an insert of several rows. Add each row with `VALUES` or `ADDVALUES`. Same as
/// `SQL.INSERT(INTO:columns:)`.
@available(macOS 14.0.0, *)
public func INSERT<T, each U>(INTO table: T,
                              columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedLoneInsertSQLQuery<T, repeat each U> {
    return SQL.INSERT(INTO: table, columns: repeat each columns)
}

/// Inserts one row of values when a condition holds: `INSERT INTO table (a, b) SELECT $1, $2 WHERE …`.
/// Same as `SQL.INSERT(INTO:columns:SELECT:)`.
public func INSERT<T, each U: Encodable>(INTO table: T,
                                         columns: repeat KeyPath<T, TableColumn<T, each U>>,
                                         SELECT values: repeat each U) -> TypedInsertSelectSQLQuery<T> {
    return SQL.INSERT(INTO: table, columns: repeat each columns, SELECT: repeat each values)
}

/// Inserts the rows a query returns: `INSERT INTO table (a, b) SELECT …`. Same as
/// `SQL.INSERT(INTO:columns:SELECT:)`.
public func INSERT<T, each U, Q: TableSQLQuery>(INTO table: T,
                                                columns: repeat KeyPath<T, TableColumn<T, each U>>,
                                                SELECT query: Q) -> TypedInsertSQLQuery<T> where Q.Row == (repeat each U) {
    return SQL.INSERT(INTO: table, columns: repeat each columns, SELECT: query)
}

// MARK: - UPDATE

/// Starts an `UPDATE` that sets columns to values: `UPDATE table SET a = $1`. Same as `SQL.UPDATE(_:SET:)`.
///
/// Each value must have its column's type. Add `WHERE` to run it.
public func UPDATE<T, each U: Encodable>(_ table: T, SET pairs: repeat (KeyPath<T, TableColumn<T, each U>>, (each U)?)) -> TypedUpdateSQLQuery<T, Void> {
    return SQL.UPDATE(table, SET: repeat each pairs)
}

/// Starts an `UPDATE` whose values can mix plain values, ``SQLExpr``, ``NOW``, ``COALESCE`` and
/// subqueries, each checked against its column's type. Same as `SQL.UPDATE(_:SET:)`.
@_disfavoredOverload
public func UPDATE<T, each U: SQLValue, each V: SQLValue>(_ table: T, SET pairs: repeat (KeyPath<T, TableColumn<T, each U>>, each V)) -> TypedUpdateSQLQuery<T, Void> where repeat (each V).SQLType == (each U).SQLType {
    return SQL.UPDATE(table, SET: repeat each pairs)
}

/// Starts an `UPDATE` with values that aren't checked against their columns.
@_disfavoredOverload
@available(*, deprecated, message: "These values aren't checked against their columns. Use values of the columns' types. In a row with an expression, conform custom types to SQLValue (extension MyType: SQLValue {}), write raw SQL as SQLExpr instead of RawSQL, and give an SQLExpr stored in a variable its column's type (SQLExpr<MyType>(…)).")
public func UPDATE<T, each U>(_ table: T, SET pairs: repeat (KeyPath<T, TableColumn<T, each U>>, Any)) -> TypedUpdateSQLQuery<T, Void> {
    return SQL.UPDATE(table, SET: repeat each pairs)
}

// MARK: - DELETE

/// Starts a `DELETE` from a table: `DELETE FROM table`. Same as `SQL.DELETE_FROM(_:)`.
///
/// Add `WHERE` to run it.
public func DELETE_FROM<T>(_ table: T) -> TypedDeleteSQLQuery<T> {
    return SQL.DELETE_FROM(table)
}

/// Starts a `DELETE` from a table: `DELETE FROM table`. Same as `SQL.DELETE(FROM:)`.
///
/// Add `WHERE` to run it.
public func DELETE<T>(FROM table: T) -> TypedDeleteSQLQuery<T> {
    return SQL.DELETE(FROM: table)
}
