//
//  SQLPredicate.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation


/// A comparison between a column of table `T`, given as a key path, and a value.
///
/// You create one with a comparison operator and pass it to `WHERE`, `AND` or `OR`:
///
/// ```swift
/// .WHERE(\.age >= 18)   // WHERE age >= $1
/// ```
///
/// The value must have the column's type, and it's bound as a parameter. A date column can
/// also be compared with ``NOW``: `\.published_at <= NOW()`.
public struct SQLPredicate<T: Table, Y: Encodable> {
    let left: KeyPath<T, TableColumn<T, Y>>
    let sign: String
    /// The right-hand side, with `?` for each bound value: `?` for a value, `now()` for ``NOW``.
    let right: SQLExpr

    init(left: KeyPath<T, TableColumn<T, Y>>, sign: String, right: Y) {
        self.left = left
        self.sign = sign
        self.right = SQLExpr(sql: "?", parameters: [right])
    }

    init(left: KeyPath<T, TableColumn<T, Y>>, sign: String, timestamp: some DatabaseTimestamp) {
        self.left = left
        self.sign = sign
        self.right = timestamp.timestampExpression
    }

    /// The condition's SQL and parameters when appended to `fragment`, with the column named
    /// as in a query on `T`: `column <op> $n`.
    func rendered(after fragment: some SQLFragment) -> (sql: String, parameters: [(any Encodable)?]) {
        let (fragments, parameters) = renderSQLValues([right], parameterOffset: fragment.parameterNumber())
        return ("\(T()[keyPath: left].name) \(sign) \(fragments[0])", parameters)
    }
}

/// A condition that the column is equal to the value: `column = $n`.
public func == <T,Y>(left: KeyPath<T, TableColumn<T, Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: "=", right: right)
}

/// A condition that the column is greater than the value: `column > $n`.
public func > <T,Y>(left: KeyPath<T, TableColumn<T, Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: ">", right: right)
}

/// A condition that the column is less than the value: `column < $n`.
public func < <T,Y>(left: KeyPath<T, TableColumn<T, Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: "<", right: right)
}

/// A condition that the column is greater than or equal to the value: `column >= $n`.
public func >= <T,Y>(left: KeyPath<T, TableColumn<T, Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: ">=", right: right)
}

/// A condition that the column is less than or equal to the value: `column <= $n`.
public func <= <T,Y>(left: KeyPath<T, TableColumn<T, Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: "<=", right: right)
}

/// A condition that the column is not equal to the value: `column != $n`.
public func != <T,Y>(left: KeyPath<T, TableColumn<T, Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: "!=", right: right)
}

/// A comparison between a table-qualified column and a value.
///
/// You create one by comparing a column value, such as `users.age`, to a value. It lets
/// `WHERE` and `AND` filter on any table in a join:
///
/// ```swift
/// .WHERE(users.age >= 18)   // WHERE users.age >= $1
/// ```
public struct TableColumnPredicate<T: Table, Y: Encodable> {
    let column: TableColumn<T, Y>
    let sign: String
    let right: Y
}

/// A condition that the qualified column is equal to the value: `table.column = $n`.
public func == <T: Table, Y: Encodable>(left: TableColumn<T, Y>, right: Y) -> TableColumnPredicate<T, Y> {
    return TableColumnPredicate(column: left, sign: "=", right: right)
}

/// A condition that the qualified column is not equal to the value: `table.column != $n`.
public func != <T: Table, Y: Encodable>(left: TableColumn<T, Y>, right: Y) -> TableColumnPredicate<T, Y> {
    return TableColumnPredicate(column: left, sign: "!=", right: right)
}

/// A condition that the qualified column is greater than the value: `table.column > $n`.
public func > <T: Table, Y: Encodable>(left: TableColumn<T, Y>, right: Y) -> TableColumnPredicate<T, Y> {
    return TableColumnPredicate(column: left, sign: ">", right: right)
}

/// A condition that the qualified column is less than the value: `table.column < $n`.
public func < <T: Table, Y: Encodable>(left: TableColumn<T, Y>, right: Y) -> TableColumnPredicate<T, Y> {
    return TableColumnPredicate(column: left, sign: "<", right: right)
}

/// A condition that the qualified column is greater than or equal to the value: `table.column >= $n`.
public func >= <T: Table, Y: Encodable>(left: TableColumn<T, Y>, right: Y) -> TableColumnPredicate<T, Y> {
    return TableColumnPredicate(column: left, sign: ">=", right: right)
}

/// A condition that the qualified column is less than or equal to the value: `table.column <= $n`.
public func <= <T: Table, Y: Encodable>(left: TableColumn<T, Y>, right: Y) -> TableColumnPredicate<T, Y> {
    return TableColumnPredicate(column: left, sign: "<=", right: right)
}
