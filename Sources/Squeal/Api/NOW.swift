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
/// Comparisons only compile with `Date` and `Date?` columns. To shift the current time, add
/// or subtract an ``INTERVAL``, such as `NOW() - INTERVAL(30, .DAY)`.
///
/// In Postgres, `now()` is the time the current transaction started, so every use of it in a
/// transaction returns the same value. To use your server's clock instead, pass `Date()` as a
/// value.
public struct NOW: SelectField, DatabaseTimestamp {

    /// Creates the `now()` expression.
    public init() {}

    public func toString() -> String {
        return "now()"
    }

    public var timestampExpression: SQLExpr {
        return SQLExpr(sql: "now()", parameters: [])
    }
}

// MARK: - Intervals

/// A length of time to add to or subtract from ``NOW``: `INTERVAL(30, .DAY)`.
///
/// It reads like SQL's `INTERVAL 30 DAY`:
///
/// ```swift
/// SQL.SELECT(\.id).FROM(posts).WHERE(\.published_at >= NOW() - INTERVAL(30, .DAY))
/// // SELECT id FROM posts WHERE published_at >= now() - $1::interval
/// // parameters: ["30 days"]
/// ```
///
/// Chain intervals for combined lengths, such as `NOW() - INTERVAL(2, .HOUR) - INTERVAL(30, .MINUTE)`.
/// Negative amounts are allowed. Like every other value, the interval is bound as a parameter.
public struct INTERVAL: Sendable, Equatable {

    /// The unit of an ``INTERVAL``.
    public enum Unit: String, Sendable {
        case YEAR = "years"
        case MONTH = "months"
        case WEEK = "weeks"
        case DAY = "days"
        case HOUR = "hours"
        case MINUTE = "minutes"
        case SECOND = "seconds"
    }

    /// The number of units.
    public let amount: Int
    /// The unit of time.
    public let unit: Unit

    /// Creates an interval of `amount` units, such as `INTERVAL(30, .DAY)`.
    public init(_ amount: Int, _ unit: Unit) {
        self.amount = amount
        self.unit = unit
    }

    /// The interval as Postgres reads it, such as `30 days`.
    public var text: String {
        return "\(amount) \(unit.rawValue)"
    }
}

/// The current time shifted by one or more intervals, such as `NOW() - INTERVAL(30, .DAY)`.
///
/// Compare a date column with it in `WHERE`, `AND` and `OR`, or use it as a value in
/// `INSERT` and `UPDATE`.
public struct ShiftedNOW: DatabaseTimestamp {
    let shifts: [(sign: String, interval: INTERVAL)]

    public var timestampExpression: SQLExpr {
        let sql = shifts.map { " \($0.sign) ?::interval" }.joined()
        return SQLExpr(sql: "now()" + sql, parameters: shifts.map { $0.interval.text })
    }
}

/// The current time minus an interval: `now() - $n::interval`.
public func - (left: NOW, right: INTERVAL) -> ShiftedNOW {
    return ShiftedNOW(shifts: [("-", right)])
}

/// The current time plus an interval: `now() + $n::interval`.
public func + (left: NOW, right: INTERVAL) -> ShiftedNOW {
    return ShiftedNOW(shifts: [("+", right)])
}

/// The shifted time minus another interval: `now() - $1::interval - $2::interval`.
public func - (left: ShiftedNOW, right: INTERVAL) -> ShiftedNOW {
    return ShiftedNOW(shifts: left.shifts + [("-", right)])
}

/// The shifted time plus another interval: `now() - $1::interval + $2::interval`.
public func + (left: ShiftedNOW, right: INTERVAL) -> ShiftedNOW {
    return ShiftedNOW(shifts: left.shifts + [("+", right)])
}

/// A timestamp computed by the database: ``NOW`` or ``ShiftedNOW``.
public protocol DatabaseTimestamp {
    /// The timestamp's SQL, with its values bound through `?` placeholders.
    var timestampExpression: SQLExpr { get }
}

// MARK: - Comparing columns with NOW()

/// A column value type that can be compared with ``NOW``: `Date` and `Date?`.
public protocol NOWComparable {}

extension Date: NOWComparable {}
extension Optional: NOWComparable where Wrapped == Date {}

/// A comparison between a date column and the database's current time, such as
/// `\.published_at < NOW()` or `\.published_at >= NOW() - INTERVAL(30, .DAY)`.
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
    let timestamp: SQLExpr

    init<V>(_ keyPath: KeyPath<T, TableColumn<T, V>>, _ sign: String, _ timestamp: some DatabaseTimestamp) {
        self.column = T()[keyPath: keyPath].name
        self.tableName = T.schema
        self.isKeyPath = true
        self.sign = sign
        self.timestamp = timestamp.timestampExpression
    }

    init<V>(_ column: TableColumn<T, V>, _ sign: String, _ timestamp: some DatabaseTimestamp) {
        self.column = column.name
        self.tableName = column.tableName
        self.isKeyPath = false
        self.sign = sign
        self.timestamp = timestamp.timestampExpression
    }

    /// The condition in a query on `Q`, with `?` placeholders for its values: key paths on `Q`
    /// render unqualified, everything else renders as `table.column`.
    func expression<Q: Table>(in query: Q.Type) -> SQLExpr {
        let name = isKeyPath && T.self == Q.self ? column : "\(tableName).\(column)"
        return SQLExpr(sql: "\(name) \(sign) \(timestamp.sql)", parameters: timestamp.parameters)
    }
}

/// A condition that the date column is before the timestamp: `column < now()`.
public func < <T, V: NOWComparable, R: DatabaseTimestamp>(left: KeyPath<T, TableColumn<T, V>>, right: R) -> NOWPredicate<T> { NOWPredicate(left, "<", right) }
/// A condition that the date column is at or before the timestamp: `column <= now()`.
public func <= <T, V: NOWComparable, R: DatabaseTimestamp>(left: KeyPath<T, TableColumn<T, V>>, right: R) -> NOWPredicate<T> { NOWPredicate(left, "<=", right) }
/// A condition that the date column is after the timestamp: `column > now()`.
public func > <T, V: NOWComparable, R: DatabaseTimestamp>(left: KeyPath<T, TableColumn<T, V>>, right: R) -> NOWPredicate<T> { NOWPredicate(left, ">", right) }
/// A condition that the date column is at or after the timestamp: `column >= now()`.
public func >= <T, V: NOWComparable, R: DatabaseTimestamp>(left: KeyPath<T, TableColumn<T, V>>, right: R) -> NOWPredicate<T> { NOWPredicate(left, ">=", right) }
/// A condition that the date column equals the timestamp: `column = now()`.
public func == <T, V: NOWComparable, R: DatabaseTimestamp>(left: KeyPath<T, TableColumn<T, V>>, right: R) -> NOWPredicate<T> { NOWPredicate(left, "=", right) }
/// A condition that the date column doesn't equal the timestamp: `column != now()`.
public func != <T, V: NOWComparable, R: DatabaseTimestamp>(left: KeyPath<T, TableColumn<T, V>>, right: R) -> NOWPredicate<T> { NOWPredicate(left, "!=", right) }

/// A condition that the date column is before the timestamp: `table.column < now()`.
public func < <T, V: NOWComparable, R: DatabaseTimestamp>(left: TableColumn<T, V>, right: R) -> NOWPredicate<T> { NOWPredicate(left, "<", right) }
/// A condition that the date column is at or before the timestamp: `table.column <= now()`.
public func <= <T, V: NOWComparable, R: DatabaseTimestamp>(left: TableColumn<T, V>, right: R) -> NOWPredicate<T> { NOWPredicate(left, "<=", right) }
/// A condition that the date column is after the timestamp: `table.column > now()`.
public func > <T, V: NOWComparable, R: DatabaseTimestamp>(left: TableColumn<T, V>, right: R) -> NOWPredicate<T> { NOWPredicate(left, ">", right) }
/// A condition that the date column is at or after the timestamp: `table.column >= now()`.
public func >= <T, V: NOWComparable, R: DatabaseTimestamp>(left: TableColumn<T, V>, right: R) -> NOWPredicate<T> { NOWPredicate(left, ">=", right) }
/// A condition that the date column equals the timestamp: `table.column = now()`.
public func == <T, V: NOWComparable, R: DatabaseTimestamp>(left: TableColumn<T, V>, right: R) -> NOWPredicate<T> { NOWPredicate(left, "=", right) }
/// A condition that the date column doesn't equal the timestamp: `table.column != now()`.
public func != <T, V: NOWComparable, R: DatabaseTimestamp>(left: TableColumn<T, V>, right: R) -> NOWPredicate<T> { NOWPredicate(left, "!=", right) }

extension SQLQuery {
    /// `keyword` followed by the predicate's SQL, with its placeholders numbered after this query's.
    func appending<U: Table, Q: Table>(_ keyword: String, _ predicate: NOWPredicate<U>, in query: Q.Type) -> (query: String, parameters: [(any Encodable)?]) {
        let (fragments, newParameters) = renderSQLValues([predicate.expression(in: query)], parameterOffset: parameterNumber())
        return (self.query + " \(keyword) \(fragments[0])", parameters + newParameters)
    }
}

public extension WHEREableQuery {
    /// Filters rows by comparing a date column with the database's current time.
    ///
    /// ```swift
    /// .WHERE(\.published_at <= NOW())                       // WHERE published_at <= now()
    /// .WHERE(\.published_at >= NOW() - INTERVAL(30, .DAY))   // WHERE published_at >= now() - $1::interval
    /// ```
    func WHERE(_ predicate: NOWPredicate<T>) -> TypedWhereSQLQuery<T, Row> {
        let (q, p) = appending("WHERE", predicate, in: T.self)
        return TypedWhereSQLQuery(for: table, query: q, parameters: p)
    }

    /// Filters rows by comparing a date column of any table in the query with the database's
    /// current time.
    ///
    /// ```swift
    /// .WHERE(posts.published_at <= NOW())   // WHERE posts.published_at <= now()
    /// ```
    func WHERE<U>(_ predicate: NOWPredicate<U>) -> TypedWhereSQLQuery<T, Row> {
        let (q, p) = appending("WHERE", predicate, in: T.self)
        return TypedWhereSQLQuery(for: table, query: q, parameters: p)
    }
}

public extension ANDableQuery {
    /// Adds a condition comparing a date column with the database's current time: `AND column < now()`.
    func AND(_ predicate: NOWPredicate<T>) -> TypedWhereSQLQuery<T, Row> {
        let (q, p) = appending("AND", predicate, in: T.self)
        return TypedWhereSQLQuery(for: table, query: q, parameters: p)
    }

    /// Adds a condition comparing a date column of any table in the query with the database's
    /// current time: `AND table.column < now()`.
    func AND<U>(_ predicate: NOWPredicate<U>) -> TypedWhereSQLQuery<T, Row> {
        let (q, p) = appending("AND", predicate, in: T.self)
        return TypedWhereSQLQuery(for: table, query: q, parameters: p)
    }
}

public extension ORableQuery {
    /// Adds an alternative condition comparing a date column with the database's current time:
    /// `OR column < now()`.
    func OR(_ predicate: NOWPredicate<T>) -> TypedWhereSQLQuery<T, Row> {
        let (q, p) = appending("OR", predicate, in: T.self)
        return TypedWhereSQLQuery(for: table, query: q, parameters: p)
    }

    /// Adds an alternative condition comparing a date column of any table in the query with the
    /// database's current time: `OR table.column < now()`.
    func OR<U>(_ predicate: NOWPredicate<U>) -> TypedWhereSQLQuery<T, Row> {
        let (q, p) = appending("OR", predicate, in: T.self)
        return TypedWhereSQLQuery(for: table, query: q, parameters: p)
    }
}
