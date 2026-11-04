//
//  SQLValue.swift
//  Squeal
//

import Foundation

/// A value that can fill a column in `INSERT … VALUES` or `UPDATE … SET`, checked against the
/// column's type.
///
/// `SQLType` is the column type the value fits, without its optional: a `String` and a
/// `String?` both fit a `String` or `String?` column.
///
/// Plain values don't need it: `VALUES` and `SET` check them against their columns directly.
/// It matters when a row mixes plain values with expressions such as ``NOW``, ``COALESCE``,
/// ``SQLExpr`` or a subquery. Every value of such a row must be an `SQLValue`, and so must
/// its column's type. Common Swift types conform. Conform your own column types with one line:
///
/// ```swift
/// extension TradeType: SQLValue {}
/// ```
public protocol SQLValue {
    /// The column type this value fits, without its optional.
    associatedtype SQLType = Self
}

extension String: SQLValue {}
extension Substring: SQLValue { public typealias SQLType = String }
extension Bool: SQLValue {}
extension Int: SQLValue {}
extension Int8: SQLValue {}
extension Int16: SQLValue {}
extension Int32: SQLValue {}
extension Int64: SQLValue {}
extension UInt: SQLValue {}
extension UInt8: SQLValue {}
extension UInt16: SQLValue {}
extension UInt32: SQLValue {}
extension UInt64: SQLValue {}
extension Float: SQLValue {}
extension Double: SQLValue {}
extension Decimal: SQLValue {}
extension UUID: SQLValue {}
extension Date: SQLValue {}
extension Data: SQLValue {}
extension Array: SQLValue where Element: SQLValue { public typealias SQLType = [Element.SQLType] }
extension Optional: SQLValue where Wrapped: SQLValue { public typealias SQLType = Wrapped.SQLType }

extension SQLExpr: SQLValue { public typealias SQLType = Value }
extension NOW: SQLValue { public typealias SQLType = Date }
extension ShiftedNOW: SQLValue { public typealias SQLType = Date }
extension COALESCE: SQLValue where Value: SQLValue { public typealias SQLType = Value.SQLType }

// A query that selects one column is a value: a parenthesized subquery of its column's type.
// `SQLType` is the selected column's exact type, so a subquery of a nullable column only fits
// with its optional: Swift can't strip it while it still infers the query's columns.
extension TypedSelectSQLQuery: SQLValue { public typealias SQLType = Row }
extension TypedFromSQLQuery: SQLValue { public typealias SQLType = Row }
extension TypedJOINSQLQuery: SQLValue { public typealias SQLType = Row }
extension TypedWhereSQLQuery: SQLValue { public typealias SQLType = Row }
extension TypedGroupBySQLQuery: SQLValue { public typealias SQLType = Row }
extension TypedHavingSQLQuery: SQLValue { public typealias SQLType = Row }
extension TypedOrderBySQLQuery: SQLValue { public typealias SQLType = Row }
extension TypedLimitSQLQuery: SQLValue { public typealias SQLType = Row }
extension TypedOffsetSQLQuery: SQLValue { public typealias SQLType = Row }

