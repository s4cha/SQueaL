//
//  NOW.swift
//  Squeal
//

import Foundation

/// The current date and time, as computed by the database: `now()`.
///
/// Use it as a value in `INSERT` and `UPDATE`, in a `SELECT` or `RETURNING` list, or compare
/// a date column with it in `WHERE`, `AND` and `OR`:
///
/// ```swift
/// SQL.UPDATE(posts, SET: (\.published_at, NOW()))
/// // UPDATE posts SET published_at = now()
///
/// SQL.SELECT(posts.id, NOW()).FROM(posts)
/// // SELECT posts.id, now() FROM posts
///
/// SQL.SELECT(\.id).FROM(posts).WHERE(\.published_at <= NOW())
/// // SELECT id FROM posts WHERE published_at <= now()
/// ```
///
/// Comparisons only compile with `Date` and `Date?` columns.
///
/// In Postgres, `now()` is the time the current transaction started, so every use of it in a
/// transaction returns the same value. To use your server's clock instead, pass `Date()` as a
/// value.
public struct NOW: SelectField {

    /// Creates the `now()` expression.
    public init() {}

    public func toString() -> String {
        return "now()"
    }
}

// MARK: - Comparing columns with NOW()

/// A column value type that can be compared with ``NOW``: `Date` and `Date?`.
public protocol NOWComparable {}

extension Date: NOWComparable {}
extension Optional: NOWComparable where Wrapped == Date {}

/// A comparison between a date column and ``NOW``, such as `\.published_at < NOW()`.
///
/// Pass it to `WHERE`, `AND` or `OR`:
///
/// ```swift
/// SQL.SELECT(\.id).FROM(posts).WHERE(\.published_at <= NOW())
/// // SELECT id FROM posts WHERE published_at <= now()
/// ```
///
/// It only compiles with `Date` and `Date?` columns.
public struct NOWPredicate<T: Table> {
    let column: String
    let tableName: String
    let isKeyPath: Bool
    let sign: String

    init<V>(_ keyPath: KeyPath<T, TableColumn<T, V>>, _ sign: String) {
        self.column = T()[keyPath: keyPath].name
        self.tableName = T.schema
        self.isKeyPath = true
        self.sign = sign
    }

    init<V>(_ column: TableColumn<T, V>, _ sign: String) {
        self.column = column.name
        self.tableName = column.tableName
        self.isKeyPath = false
        self.sign = sign
    }

    /// The condition's SQL in a query on `Q`: key paths on `Q` render unqualified,
    /// everything else renders as `table.column`.
    func sql<Q: Table>(in query: Q.Type) -> String {
        let name = isKeyPath && T.self == Q.self ? column : "\(tableName).\(column)"
        return "\(name) \(sign) now()"
    }
}

/// A condition that the date column is before the current time: `column < now()`.
public func < <T, V: NOWComparable>(left: KeyPath<T, TableColumn<T, V>>, right: NOW) -> NOWPredicate<T> { NOWPredicate(left, "<") }
/// A condition that the date column is at or before the current time: `column <= now()`.
public func <= <T, V: NOWComparable>(left: KeyPath<T, TableColumn<T, V>>, right: NOW) -> NOWPredicate<T> { NOWPredicate(left, "<=") }
/// A condition that the date column is after the current time: `column > now()`.
public func > <T, V: NOWComparable>(left: KeyPath<T, TableColumn<T, V>>, right: NOW) -> NOWPredicate<T> { NOWPredicate(left, ">") }
/// A condition that the date column is at or after the current time: `column >= now()`.
public func >= <T, V: NOWComparable>(left: KeyPath<T, TableColumn<T, V>>, right: NOW) -> NOWPredicate<T> { NOWPredicate(left, ">=") }
/// A condition that the date column equals the current time: `column = now()`.
public func == <T, V: NOWComparable>(left: KeyPath<T, TableColumn<T, V>>, right: NOW) -> NOWPredicate<T> { NOWPredicate(left, "=") }
/// A condition that the date column doesn't equal the current time: `column != now()`.
public func != <T, V: NOWComparable>(left: KeyPath<T, TableColumn<T, V>>, right: NOW) -> NOWPredicate<T> { NOWPredicate(left, "!=") }

/// A condition that the date column is before the current time: `table.column < now()`.
public func < <T, V: NOWComparable>(left: TableColumn<T, V>, right: NOW) -> NOWPredicate<T> { NOWPredicate(left, "<") }
/// A condition that the date column is at or before the current time: `table.column <= now()`.
public func <= <T, V: NOWComparable>(left: TableColumn<T, V>, right: NOW) -> NOWPredicate<T> { NOWPredicate(left, "<=") }
/// A condition that the date column is after the current time: `table.column > now()`.
public func > <T, V: NOWComparable>(left: TableColumn<T, V>, right: NOW) -> NOWPredicate<T> { NOWPredicate(left, ">") }
/// A condition that the date column is at or after the current time: `table.column >= now()`.
public func >= <T, V: NOWComparable>(left: TableColumn<T, V>, right: NOW) -> NOWPredicate<T> { NOWPredicate(left, ">=") }
/// A condition that the date column equals the current time: `table.column = now()`.
public func == <T, V: NOWComparable>(left: TableColumn<T, V>, right: NOW) -> NOWPredicate<T> { NOWPredicate(left, "=") }
/// A condition that the date column doesn't equal the current time: `table.column != now()`.
public func != <T, V: NOWComparable>(left: TableColumn<T, V>, right: NOW) -> NOWPredicate<T> { NOWPredicate(left, "!=") }

public extension WHEREableQuery {
    /// Filters rows by comparing a date column with the current time.
    ///
    /// ```swift
    /// .WHERE(\.published_at <= NOW())   // WHERE published_at <= now()
    /// ```
    func WHERE(_ predicate: NOWPredicate<T>) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(predicate.sql(in: T.self))", parameters: parameters)
    }

    /// Filters rows by comparing a date column of any table in the query with the current time.
    ///
    /// ```swift
    /// .WHERE(posts.published_at <= NOW())   // WHERE posts.published_at <= now()
    /// ```
    func WHERE<U>(_ predicate: NOWPredicate<U>) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(predicate.sql(in: T.self))", parameters: parameters)
    }
}

public extension ANDableQuery {
    /// Adds a condition comparing a date column with the current time: `AND column < now()`.
    func AND(_ predicate: NOWPredicate<T>) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " AND \(predicate.sql(in: T.self))", parameters: parameters)
    }

    /// Adds a condition comparing a date column of any table in the query with the current
    /// time: `AND table.column < now()`.
    func AND<U>(_ predicate: NOWPredicate<U>) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " AND \(predicate.sql(in: T.self))", parameters: parameters)
    }
}

public extension ORableQuery {
    /// Adds an alternative condition comparing a date column with the current time: `OR column < now()`.
    func OR(_ predicate: NOWPredicate<T>) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " OR \(predicate.sql(in: T.self))", parameters: parameters)
    }

    /// Adds an alternative condition comparing a date column of any table in the query with
    /// the current time: `OR table.column < now()`.
    func OR<U>(_ predicate: NOWPredicate<U>) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " OR \(predicate.sql(in: T.self))", parameters: parameters)
    }
}
