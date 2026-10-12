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
    func JOIN<Y: Table, F>(_ table2: Y, ON: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T, Row>
    /// Joins another table: `INNER JOIN table2 ON a = b`.
    ///
    /// Put the `FROM` table's column on the left of the condition.
    func INNER_JOIN<Y: Table, F>(_ table2: Y, ON: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T, Row>
    /// Joins another table, keeping rows with no match: `LEFT JOIN table2 ON a = b`.
    ///
    /// Put the `FROM` table's column on the left of the condition.
    func LEFT_JOIN<Y: Table, F>(_ table2: Y, ON: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T, Row>
    /// Joins another table, keeping its rows with no match: `RIGHT JOIN table2 ON a = b`.
    ///
    /// Put the `FROM` table's column on the left of the condition.
    func RIGHT_JOIN<Y: Table, F>(_ table2: Y, ON: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T, Row>
    /// Joins another table, keeping unmatched rows from both: `FULL OUTER JOIN table2 ON a = b`.
    ///
    /// Put the `FROM` table's column on the left of the condition.
    func FULL_OUTER_JOIN<Y: Table, F>(_ table2: Y, ON: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T, Row>
}

public extension JoinableQuery {
    
    /// Joins another table: `JOIN table2 ON a = b`.
    ///
    /// ```swift
    /// SQL.SELECT(posts.title, users.name)
    ///     .FROM(posts)
    ///     .JOIN(users, ON: posts.author_id == users.id)
    /// // SELECT posts.title, users.name FROM posts JOIN users ON posts.author_id = users.id
    /// ```
    func JOIN<Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: "", table2, ON: predicate)
    }
    
    /// Joins another table, with the joined table's column on the left of the condition.
    func JOIN<Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<Y, T, F>) -> TypedFromSQLQuery<T, Row> {
        return joinReverse(word: "", table2, ON: predicate)
    }
    
    /// Joins another table: `INNER JOIN table2 ON a = b`.
    ///
    /// Put the `FROM` table's column on the left of the condition.
    func INNER_JOIN<Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: " INNER", table2, ON: predicate)
    }
    
    /// Joins another table, keeping rows with no match: `LEFT JOIN table2 ON a = b`.
    ///
    /// Put the `FROM` table's column on the left of the condition.
    func LEFT_JOIN<Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: " LEFT", table2, ON: predicate)
    }
    
    /// Joins another table, keeping its rows with no match: `RIGHT JOIN table2 ON a = b`.
    ///
    /// Put the `FROM` table's column on the left of the condition.
    func RIGHT_JOIN<Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: " RIGHT", table2, ON: predicate)
    }
    
    /// Joins another table, keeping unmatched rows from both: `FULL OUTER JOIN table2 ON a = b`.
    ///
    /// Put the `FROM` table's column on the left of the condition.
    func FULL_OUTER_JOIN<Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T, Row> {
        return join(word: " FULL OUTER", table2, ON: predicate)
    }
    
    private func join<Y: Table, F>(word: String, _ table2: Y, ON predicate: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T, Row> {
        let statement = "\(word) JOIN \(Y.schema) ON \(predicate.left.tableName).\(predicate.left.name) = \(predicate.right.tableName).\(predicate.right.name)"
        return TypedFromSQLQuery(for: table,
                                 query: query + statement,
                                 parameters: parameters)
    }
    
    private func joinReverse<Y: Table, F>(word: String, _ table2: Y, ON predicate: JOINPredicate<Y, T, F>) -> TypedFromSQLQuery<T, Row> {
        let statement = "\(word) JOIN \(Y.schema) ON \(predicate.left.tableName).\(predicate.left.name) = \(predicate.right.tableName).\(predicate.right.name)"
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
