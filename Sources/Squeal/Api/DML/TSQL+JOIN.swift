//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

public struct TypedJOINSQLQuery<T: Table>: TableSQLQuery {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
    
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}


public protocol JoinableQuery: TableSQLQuery {

    func JOIN<Y: Table, F>(_ table2: Y, ON: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T>
    func INNER_JOIN<Y: Table, F>(_ table2: Y, ON: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T>
    func LEFT_JOIN<Y: Table, F>(_ table2: Y, ON: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T>
    func RIGHT_JOIN<Y: Table, F>(_ table2: Y, ON: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T>
    func FULL_OUTER_JOIN<Y: Table, F>(_ table2: Y, ON: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T>
}

public extension JoinableQuery {
    
    func JOIN<Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T> {
        return join(word: "", table2, ON: predicate)
    }
    
    func JOIN<Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<Y, T, F>) -> TypedFromSQLQuery<T> {
        return joinReverse(word: "", table2, ON: predicate)
    }
    
    func INNER_JOIN<Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T> {
        return join(word: " INNER", table2, ON: predicate)
    }
    
    func LEFT_JOIN<Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T> {
        return join(word: " LEFT", table2, ON: predicate)
    }
    
    func RIGHT_JOIN<Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T> {
        return join(word: " RIGHT", table2, ON: predicate)
    }
    
    func FULL_OUTER_JOIN<Y: Table, F>(_ table2: Y, ON predicate: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T> {
        return join(word: " FULL OUTER", table2, ON: predicate)
    }
    
    private func join<Y: Table, F>(word: String, _ table2: Y, ON predicate: JOINPredicate<T, Y, F>) -> TypedFromSQLQuery<T> {
        let statement = "\(word) JOIN \(Y.schema) ON \(predicate.left.tableName).\(predicate.left.name) = \(predicate.right.tableName).\(predicate.right.name)"
        return TypedFromSQLQuery(for: table,
                                 query: query + statement,
                                 parameters: parameters)
    }
    
    private func joinReverse<Y: Table, F>(word: String, _ table2: Y, ON predicate: JOINPredicate<Y, T, F>) -> TypedFromSQLQuery<T> {
        let statement = "\(word) JOIN \(Y.schema) ON \(predicate.left.tableName).\(predicate.left.name) = \(predicate.right.tableName).\(predicate.right.name)"
        return TypedFromSQLQuery(for: table,
                                 query: query + statement,
                                 parameters: parameters)
    }
}




public struct JOINPredicate<A: Table, B: Table, F> {
    let left: TableColumn<A, F>
    let right: TableColumn<B, F>
    let sign: String
}

public func == <A,B,F>(left: TableColumn<A, F>, right: TableColumn<B, F>) -> JOINPredicate<A,B,F> {
    return JOINPredicate(left: left, right: right, sign: "=") //SQLPredicate(left: left, sign: "=", right: right)
}
