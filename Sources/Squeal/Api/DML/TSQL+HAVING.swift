//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


/// A query after its `HAVING` clause. Next, you can add `ORDER_BY`, `LIMIT` or `OFFSET`.
public struct TypedHavingSQLQuery<T: Table, Row>: TableSQLQuery, LimitableQuery, OffsetableQuery, OrderByableQuery {
    
    public let table: T
    public var query: String
    public var parameters: [(any Encodable)?]
    
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }
}

/// A query that can be followed by a `HAVING` clause.
public protocol HavingableQuery: TableSQLQuery {
    
}

public extension HavingableQuery {
    
    /// Filters groups by comparing an aggregate to a value, which is bound as a parameter.
    ///
    /// ```swift
    /// SQL.SELECT(posts.author_id, COUNT(*))
    ///     .FROM(posts)
    ///     .GROUP_BY(\.author_id)
    ///     .HAVING(COUNT(*) >= minimumPosts)
    /// // SELECT posts.author_id, COUNT(*) FROM posts GROUP BY author_id HAVING COUNT(*) >= $1
    /// ```
    func HAVING(_ predicate: AggregatePredicate) -> TypedHavingSQLQuery<T, Row> {
        return TypedHavingSQLQuery(for: table,
                                   query: query + " HAVING \(predicate.aggregate) \(predicate.sign) \(nextDollarSign())",
                                   parameters: parameters + [predicate.value])
    }

    /// Filters groups with a SQL expression whose `?` placeholders are bound as parameters.
    ///
    /// Use it for conditions a single comparison can't express:
    ///
    /// ```swift
    /// .GROUP_BY(\.author_id)
    /// .HAVING(SQLExpr("COUNT(*) >= ? AND SUM(likes) > ?", 5, 100))
    /// // HAVING COUNT(*) >= $1 AND SUM(likes) > $2
    /// ```
    func HAVING(_ expression: SQLExpr) -> TypedHavingSQLQuery<T, Row> {
        let (fragments, newParameters) = renderSQLValues([expression], parameterOffset: parameterNumber())
        return TypedHavingSQLQuery(for: table, query: query + " HAVING \(fragments[0])", parameters: parameters + newParameters)
    }
}

// MARK: - Aggregate comparisons

/// An aggregate function that can be compared in a `HAVING` clause:
/// ``COUNT``, ``SUM``, ``AVG``, ``MIN`` or ``MAX``.
public protocol SQLAggregate: SelectField {}

extension COUNT: SQLAggregate {}
extension SUM: SQLAggregate {}
extension AVG: SQLAggregate {}
extension MIN: SQLAggregate {}
extension MAX: SQLAggregate {}

/// A comparison between an aggregate and a value, for `HAVING`.
///
/// You create one by comparing an aggregate with an operator, such as `COUNT(*) >= 5` or
/// `SUM(posts.likes) > 100`. The value is bound as a parameter.
public struct AggregatePredicate {
    let aggregate: String
    let sign: String
    let value: any Encodable
}

/// A condition that the aggregate equals the value: `COUNT(*) = $n`.
public func == <A: SQLAggregate, V: Encodable>(left: A, right: V) -> AggregatePredicate {
    AggregatePredicate(aggregate: left.toString(), sign: "=", value: right)
}

/// A condition that the aggregate doesn't equal the value: `COUNT(*) != $n`.
public func != <A: SQLAggregate, V: Encodable>(left: A, right: V) -> AggregatePredicate {
    AggregatePredicate(aggregate: left.toString(), sign: "!=", value: right)
}

/// A condition that the aggregate is greater than the value: `COUNT(*) > $n`.
public func > <A: SQLAggregate, V: Encodable>(left: A, right: V) -> AggregatePredicate {
    AggregatePredicate(aggregate: left.toString(), sign: ">", value: right)
}

/// A condition that the aggregate is less than the value: `COUNT(*) < $n`.
public func < <A: SQLAggregate, V: Encodable>(left: A, right: V) -> AggregatePredicate {
    AggregatePredicate(aggregate: left.toString(), sign: "<", value: right)
}

/// A condition that the aggregate is greater than or equal to the value: `COUNT(*) >= $n`.
public func >= <A: SQLAggregate, V: Encodable>(left: A, right: V) -> AggregatePredicate {
    AggregatePredicate(aggregate: left.toString(), sign: ">=", value: right)
}

/// A condition that the aggregate is less than or equal to the value: `COUNT(*) <= $n`.
public func <= <A: SQLAggregate, V: Encodable>(left: A, right: V) -> AggregatePredicate {
    AggregatePredicate(aggregate: left.toString(), sign: "<=", value: right)
}

