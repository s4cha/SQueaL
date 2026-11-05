//
//  SELECT.swift
//  Squeal
//

// `SELECT` without the `SQL.` prefix, so subqueries read like SQL:
//
//     .WHERE(EXISTS(SELECT(1).FROM(posts).WHERE(posts.author_id == users.id)))
//
// Each one is the same as its `SQL.SELECT` twin.

/// Selects every column: `SELECT *`. Same as `SQL.SELECT(*)`.
///
/// - Parameter function: Pass `*`.
public func SELECT(_ function: (Int, Int) -> Int) -> SelectSQLQuery {
    return SQL.SELECT(function)
}

/// Selects table-qualified columns, aggregates or raw expressions. Same as
/// `SQL.SELECT(posts.title, COUNT(*))`.
public func SELECT<each Z: SelectField>(_ fields: repeat each Z) -> SelectSQLQuery {
    return SQL.SELECT(repeat each fields)
}

/// Selects columns, given as key paths: `SELECT a, b`. Same as `SQL.SELECT(\.id, \.name)`.
///
/// The selected columns' types become the query's `Row` type, so the query can serve as a
/// typed subquery:
///
/// ```swift
/// .WHERE(\.id, IN: SELECT(\.author_id).FROM(posts).WHERE(\.likes > 1000))
/// ```
public func SELECT<T, each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSelectSQLQuery<T, (repeat each U)> {
    return SQL.SELECT(repeat each columns)
}

/// Selects the distinct values of columns: `SELECT DISTINCT …`. Same as `SQL.SELECT_DISTINCT(\.age)`.
public func SELECT_DISTINCT<T, each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSelectSQLQuery<T, (repeat each U)> {
    return SQL.SELECT_DISTINCT(repeat each columns)
}

/// Selects columns renamed with `AS`. Same as `SQL.SELECT((\UserTable.id, AS: "user_id"))`.
public func SELECT<T, each U>(_ aliases: repeat (KeyPath<T, TableColumn<T, each U>>, AS: String)) -> SelectSQLQuery {
    return SQL.SELECT(repeat each aliases)
}

/// Selects the distinct values of columns renamed with `AS`. Same as `SQL.SELECT_DISTINCT((\UserTable.age, AS: "a"))`.
public func SELECT_DISTINCT<T, each U>(_ aliases: repeat (KeyPath<T, TableColumn<T, each U>>, AS: String)) -> SelectSQLQuery {
    return SQL.SELECT_DISTINCT(repeat each aliases)
}

/// Selects a number, as in `EXISTS (SELECT 1 FROM …)`: `SELECT 1`. Same as `SQL.SELECT(1)`.
///
/// ```swift
/// EXISTS(SELECT(1).FROM(memberships).WHERE(memberships.user_id == userId))
/// // EXISTS (SELECT 1 FROM memberships WHERE memberships.user_id = $1)
/// ```
public func SELECT(_ number: Int) -> TypedSelectNumberSQLQuery {
    return SQL.SELECT(number)
}

/// Selects values without a table: `SELECT $1, $2`. Same as `SQL.SELECT(teamId, userId)`.
public func SELECT<each V: Encodable>(_ values: repeat each V) -> TypedValuesSelectSQLQuery<(repeat each V)> {
    return SQL.SELECT(repeat each values)
}
