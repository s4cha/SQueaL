//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

/// A query with a join. Joins currently return ``TypedFromSQLQuery``.
public struct TypedJOINSQLQuery<T: Table, Row>: TableSQLQuery {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
    
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = normalizedParameters(parameters)
    }
}


/// A query that can be followed by a join.
public protocol JoinableQuery: TableSQLQuery {
    /// Joins another table: `JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func JOIN<A: Table, Y: Table, F>(_ table2: Y, ON: JOINPredicate<A, Y, F>) -> TypedFromSQLQuery<T, Row>
    /// Joins another table: `JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func JOIN<A: Table, Y: Table, F>(_ table2: Y, ON: JOINPredicate<Y, A, F>) -> TypedFromSQLQuery<T, Row>
    /// Joins another table: `INNER JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func INNER_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON: JOINPredicate<A, Y, F>) -> TypedFromSQLQuery<T, Row>
    /// Joins another table: `INNER JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func INNER_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON: JOINPredicate<Y, A, F>) -> TypedFromSQLQuery<T, Row>
    /// Joins another table, keeping rows with no match: `LEFT JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func LEFT_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON: JOINPredicate<A, Y, F>) -> TypedFromSQLQuery<T, Row>
    /// Joins another table, keeping rows with no match: `LEFT JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func LEFT_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON: JOINPredicate<Y, A, F>) -> TypedFromSQLQuery<T, Row>
    /// Joins another table, keeping its rows with no match: `RIGHT JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func RIGHT_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON: JOINPredicate<A, Y, F>) -> TypedFromSQLQuery<T, Row>
    /// Joins another table, keeping its rows with no match: `RIGHT JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func RIGHT_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON: JOINPredicate<Y, A, F>) -> TypedFromSQLQuery<T, Row>
    /// Joins another table, keeping unmatched rows from both: `FULL OUTER JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func FULL_OUTER_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON: JOINPredicate<A, Y, F>) -> TypedFromSQLQuery<T, Row>
    /// Joins another table, keeping unmatched rows from both: `FULL OUTER JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func FULL_OUTER_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON: JOINPredicate<Y, A, F>) -> TypedFromSQLQuery<T, Row>
}

public extension JoinableQuery {

    /// Joins another table: `JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    ///
    /// ```swift
    /// SELECT(users.name, posts.title, comments.body)
    ///     .FROM(users)
    ///     .JOIN(posts, ON: posts.author_id == users.id)
    ///     .JOIN(comments, ON: comments.post_id == posts.id)
    /// // SELECT users.name, posts.title, comments.body FROM users
    /// //     JOIN posts ON posts.author_id = users.id JOIN comments ON comments.post_id = posts.id
    /// ```
    func JOIN<A: Table, Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<A, Y, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: "", Y.schema, ON: predicate)
    }

    /// Joins another table: `JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func JOIN<A: Table, Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<Y, A, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: "", Y.schema, ON: predicate)
    }

    /// Joins another table: `INNER JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func INNER_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<A, Y, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: " INNER", Y.schema, ON: predicate)
    }

    /// Joins another table: `INNER JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func INNER_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<Y, A, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: " INNER", Y.schema, ON: predicate)
    }

    /// Joins another table, keeping rows with no match: `LEFT JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func LEFT_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<A, Y, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: " LEFT", Y.schema, ON: predicate)
    }

    /// Joins another table, keeping rows with no match: `LEFT JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func LEFT_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<Y, A, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: " LEFT", Y.schema, ON: predicate)
    }

    /// Joins another table, keeping its rows with no match: `RIGHT JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func RIGHT_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<A, Y, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: " RIGHT", Y.schema, ON: predicate)
    }

    /// Joins another table, keeping its rows with no match: `RIGHT JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func RIGHT_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<Y, A, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: " RIGHT", Y.schema, ON: predicate)
    }

    /// Joins another table, keeping unmatched rows from both: `FULL OUTER JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func FULL_OUTER_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<A, Y, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: " FULL OUTER", Y.schema, ON: predicate)
    }

    /// Joins another table, keeping unmatched rows from both: `FULL OUTER JOIN table2 ON a = b`.
    ///
    /// The condition compares a column of the joined table with a column of the same type
    /// from any table in the query: the `FROM` table or one joined earlier. The columns can be
    /// written in either order.
    func FULL_OUTER_JOIN<A: Table, Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<Y, A, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: " FULL OUTER", Y.schema, ON: predicate)
    }

    private func join<A: Table, B: Table, F>(word: String, _ schema: String, ON predicate: JOINPredicate<A, B, F>) -> TypedFromSQLQuery<T, Row> {
        let statement = "\(word) JOIN \(schema) ON \(predicate.sql)"
        return TypedFromSQLQuery(for: table,
                                 query: query + statement,
                                 parameters: parameters)
    }
}

/// A comparison between two table-qualified columns of the same type, such as `posts.author_id == users.id`.
///
/// Use it as a `JOIN … ON` condition, or in `WHERE`, `AND` and `OR`, for example to compare
/// a column of a subquery's table with a column of the outer query:
///
/// ```swift
/// .WHERE(posts.author_id == users.id)        // WHERE posts.author_id = users.id
/// .AND(orders.shipped_at > orders.created_at) // AND orders.shipped_at > orders.created_at
/// ```
///
/// A nullable column can be compared with a non-nullable column of the same wrapped type,
/// such as a nullable foreign key with the primary key it references.
public struct JOINPredicate<A: Table, B: Table, F> {
    let left: String
    let sign: String
    let right: String

    init<L, R>(_ left: TableColumn<A, L>, _ sign: String, _ right: TableColumn<B, R>) {
        self.left = left.toString()
        self.sign = sign
        self.right = right.toString()
    }

    /// The condition as SQL: `a.x = b.y`.
    var sql: String { "\(left) \(sign) \(right)" }
}

/// Two columns are equal: `a.x = b.y`. Both columns must have the same type.
public func == <A,B,F>(left: TableColumn<A, F>, right: TableColumn<B, F>) -> JOINPredicate<A,B,F> { JOINPredicate(left, "=", right) }
/// A nullable column equals a non-nullable column: `a.x = b.y`.
public func == <A,B,F>(left: TableColumn<A, F?>, right: TableColumn<B, F>) -> JOINPredicate<A,B,F> { JOINPredicate(left, "=", right) }
/// A column equals a nullable column: `a.x = b.y`.
public func == <A,B,F>(left: TableColumn<A, F>, right: TableColumn<B, F?>) -> JOINPredicate<A,B,F> { JOINPredicate(left, "=", right) }

/// Two columns differ: `a.x != b.y`.
public func != <A,B,F>(left: TableColumn<A, F>, right: TableColumn<B, F>) -> JOINPredicate<A,B,F> { JOINPredicate(left, "!=", right) }
/// A nullable column differs from a non-nullable column: `a.x != b.y`.
public func != <A,B,F>(left: TableColumn<A, F?>, right: TableColumn<B, F>) -> JOINPredicate<A,B,F> { JOINPredicate(left, "!=", right) }
/// A column differs from a nullable column: `a.x != b.y`.
public func != <A,B,F>(left: TableColumn<A, F>, right: TableColumn<B, F?>) -> JOINPredicate<A,B,F> { JOINPredicate(left, "!=", right) }

/// A column is less than another: `a.x < b.y`.
public func < <A,B,F>(left: TableColumn<A, F>, right: TableColumn<B, F>) -> JOINPredicate<A,B,F> { JOINPredicate(left, "<", right) }
/// A nullable column is less than a non-nullable column: `a.x < b.y`.
public func < <A,B,F>(left: TableColumn<A, F?>, right: TableColumn<B, F>) -> JOINPredicate<A,B,F> { JOINPredicate(left, "<", right) }
/// A column is less than a nullable column: `a.x < b.y`.
public func < <A,B,F>(left: TableColumn<A, F>, right: TableColumn<B, F?>) -> JOINPredicate<A,B,F> { JOINPredicate(left, "<", right) }

/// A column is less than or equal to another: `a.x <= b.y`.
public func <= <A,B,F>(left: TableColumn<A, F>, right: TableColumn<B, F>) -> JOINPredicate<A,B,F> { JOINPredicate(left, "<=", right) }
/// A nullable column is less than or equal to a non-nullable column: `a.x <= b.y`.
public func <= <A,B,F>(left: TableColumn<A, F?>, right: TableColumn<B, F>) -> JOINPredicate<A,B,F> { JOINPredicate(left, "<=", right) }
/// A column is less than or equal to a nullable column: `a.x <= b.y`.
public func <= <A,B,F>(left: TableColumn<A, F>, right: TableColumn<B, F?>) -> JOINPredicate<A,B,F> { JOINPredicate(left, "<=", right) }

/// A column is greater than another: `a.x > b.y`.
public func > <A,B,F>(left: TableColumn<A, F>, right: TableColumn<B, F>) -> JOINPredicate<A,B,F> { JOINPredicate(left, ">", right) }
/// A nullable column is greater than a non-nullable column: `a.x > b.y`.
public func > <A,B,F>(left: TableColumn<A, F?>, right: TableColumn<B, F>) -> JOINPredicate<A,B,F> { JOINPredicate(left, ">", right) }
/// A column is greater than a nullable column: `a.x > b.y`.
public func > <A,B,F>(left: TableColumn<A, F>, right: TableColumn<B, F?>) -> JOINPredicate<A,B,F> { JOINPredicate(left, ">", right) }

/// A column is greater than or equal to another: `a.x >= b.y`.
public func >= <A,B,F>(left: TableColumn<A, F>, right: TableColumn<B, F>) -> JOINPredicate<A,B,F> { JOINPredicate(left, ">=", right) }
/// A nullable column is greater than or equal to a non-nullable column: `a.x >= b.y`.
public func >= <A,B,F>(left: TableColumn<A, F?>, right: TableColumn<B, F>) -> JOINPredicate<A,B,F> { JOINPredicate(left, ">=", right) }
/// A column is greater than or equal to a nullable column: `a.x >= b.y`.
public func >= <A,B,F>(left: TableColumn<A, F>, right: TableColumn<B, F?>) -> JOINPredicate<A,B,F> { JOINPredicate(left, ">=", right) }
