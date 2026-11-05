//
//  EXISTS.swift
//  Squeal
//

/// A condition that a subquery returns at least one row: `EXISTS (SELECT …)`.
///
/// Use it in `WHERE`, `AND` or `OR`. The subquery usually refers to the outer query's table
/// with a column comparison:
///
/// ```swift
/// SELECT(\.id, \.name)
///     .FROM(users)
///     .WHERE(EXISTS(SELECT(1).FROM(posts).WHERE(posts.author_id == users.id).AND(\.likes > 1000)))
/// // SELECT id, name FROM users
/// //     WHERE EXISTS (SELECT 1 FROM posts WHERE posts.author_id = users.id AND likes > $1)
/// ```
///
/// The subquery's placeholders are renumbered to follow the outer query's placeholders.
public struct EXISTS {
    let subquery: any TableSQLQuery

    /// A condition that `subquery` returns at least one row.
    public init(_ subquery: some TableSQLQuery) {
        self.subquery = subquery
    }

    func sql(after outer: some SQLFragment) -> String {
        return "EXISTS (\(outer.embedded(subquery)))"
    }
}

/// A condition that a subquery returns no row: `NOT EXISTS (SELECT …)`.
///
/// ```swift
/// SELECT(\.id, \.name)
///     .FROM(users)
///     .WHERE(NOT_EXISTS(SELECT(1).FROM(posts).WHERE(posts.author_id == users.id)))
/// // SELECT id, name FROM users WHERE NOT EXISTS (SELECT 1 FROM posts WHERE posts.author_id = users.id)
/// ```
public struct NOT_EXISTS {
    let subquery: any TableSQLQuery

    /// A condition that `subquery` returns no row.
    public init(_ subquery: some TableSQLQuery) {
        self.subquery = subquery
    }

    func sql(after outer: some SQLFragment) -> String {
        return "NOT EXISTS (\(outer.embedded(subquery)))"
    }
}
