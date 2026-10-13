//
//  NOW.swift
//  Squeal
//

import Foundation

/// The current date and time, as computed by the database: `now()`.
///
/// Use it as a value in `INSERT` and `UPDATE`, or in a `SELECT` or `RETURNING` list:
///
/// ```swift
/// SQL.UPDATE(posts, SET: (\.published_at, NOW()))
/// // UPDATE posts SET published_at = now()
///
/// SQL.SELECT(posts.id, NOW()).FROM(posts)
/// // SELECT posts.id, now() FROM posts
/// ```
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
