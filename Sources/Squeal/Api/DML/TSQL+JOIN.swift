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
        self.parameters = parameters
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
    /// SQL.SELECT(users.name, posts.title, comments.body)
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
        let statement = "\(word) JOIN \(schema) ON \(predicate.left.tableName).\(predicate.left.name) = \(predicate.right.tableName).\(predicate.right.name)"
        return TypedFromSQLQuery(for: table,
                                 query: query + statement,
                                 parameters: parameters)
    }
}




/// A join condition between two columns of the same type.
///
/// You create one by comparing two table-qualified columns with `==`: `posts.author_id == users.id`.
public struct JOINPredicate<A: Table, B: Table, F> {
    let left: TableColumn<A, F>
    let right: TableColumn<B, F>
    let sign: String
}

/// A join condition that two columns are equal. Both columns must have the same type.
public func == <A,B,F>(left: TableColumn<A, F>, right: TableColumn<B, F>) -> JOINPredicate<A,B,F> {
    return JOINPredicate(left: left, right: right, sign: "=") //SQLPredicate(left: left, sign: "=", right: right)
}
