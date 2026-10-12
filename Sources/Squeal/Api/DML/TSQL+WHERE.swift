//
//  SQL+WHERE.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation

// TODO try return WHereClause?
/// A query after its `WHERE` clause.
///
/// Next, you can add `AND`, `OR`, `GROUP_BY`, `ORDER_BY`, `LIMIT` or `OFFSET`.
public protocol WHEREClause: TableSQLQuery, ANDableQuery, ORableQuery, GroupByableQuery, OrderByableQuery, LimitableQuery, OffsetableQuery {
    
}

/// A query after a `WHERE`, `AND` or `OR` condition.
///
/// In an `UPDATE` or `DELETE`, you can follow it with `RETURNING`.
public struct TypedWhereSQLQuery<T: Table, Row>: WHEREClause {
    
    
    public let table: T
    public var query: String = ""
    public var parameters: [(any Encodable)?]
        
    init(for table: T, query: String, parameters: [(any Encodable)?]) {
        self.table = table
        self.query = query
        self.parameters = parameters
    }

    /// Returns a column of the affected rows: `RETURNING column`.
    public func RETURNING<U>(_ kp: KeyPath<T, TableColumn<T, U>>) -> TypedSQLQuery<T, Void> {
        return TypedSQLQuery(for: table, query: query + " RETURNING \(table[keyPath: kp].name)", parameters: parameters)
    }

    /// Returns columns of the affected rows: `RETURNING a, b, …`.
    ///
    /// ```swift
    /// SQL.UPDATE(users, SET: (\.name, "Ada")).WHERE(\.id == id).RETURNING(\.id, \.name)
    /// // UPDATE users SET name = $1 WHERE id = $2 RETURNING id, name
    /// ```
    public func RETURNING<each U>(_ columns: repeat KeyPath<T, TableColumn<T, each U>>) -> TypedSQLQuery<T, Void> {
        var columnNames = [String]()
        for column in repeat each columns {
            columnNames.append(table[keyPath: column].name)
        }
        return TypedSQLQuery(for: table, query: query + " RETURNING \(columnNames.joined(separator: ", "))", parameters: parameters)
    }

    /// Returns every column of the affected rows: `RETURNING *`.
    ///
    /// - Parameter all: Pass `*`.
    public func RETURNING(_ all: (Int, Int) -> Int) -> TypedSQLQuery<T, Void> {
        return TypedSQLQuery(for: table, query: query + " RETURNING *", parameters: parameters)
    }

    /// RETURNING mixing table columns (`table.column`) and `RawSQL` expressions.
    public func RETURNING<each F: SelectField>(_ fields: repeat each F) -> TypedSQLQuery<T, Void> {
        return TypedSQLQuery(for: table, query: query + returningClause(repeat each fields), parameters: parameters)
    }
}

/// A `WHERE` on a column, waiting for ``IS_NULL`` or ``IS_NOT_NULL``.
///
/// ```swift
/// .WHERE(\.bio).IS_NULL   // WHERE bio IS NULL
/// ```
public struct PartialTypedWhereSQLQuery<T: Table, U, Row>: TableSQLQuery {
    
    public let table: T
    public var query: String = ""
    public var parameters: [(any Encodable)?]
    /// The column being tested.
    public let keypath: KeyPath<T, TableColumn<T, U>>
        
    init(for table: T, query: String, parameters: [(any Encodable)?], keypath: KeyPath<T, TableColumn<T, U>>) {
        self.table = table
        self.query = query
        self.parameters = parameters
        self.keypath = keypath
    }
}

public extension PartialTypedWhereSQLQuery {
    /// Matches rows where the column is `NULL`: `WHERE column IS NULL`.
    var IS_NULL: TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table,
                                  query: query + " WHERE \(table[keyPath: keypath].name) IS NULL",
                                  parameters: parameters)
    }
    
    /// Matches rows where the column isn't `NULL`: `WHERE column IS NOT NULL`.
    var IS_NOT_NULL: TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table,
                                  query: query + " WHERE \(table[keyPath: keypath].name) IS NOT NULL",
                                  parameters: parameters)
    }
}

/// A query that can be followed by a `WHERE` clause.
public protocol WHEREableQuery: TableSQLQuery {
    /// Matches rows whose column is in a list of values: `WHERE column IN ($1, $2, …)`.
    ///
    /// ```swift
    /// .WHERE(\.name, IN: ["Ada", "Grace"])   // WHERE name IN ($1, $2)
    /// ```
    func WHERE<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, IN values: [U]) -> TypedWhereSQLQuery<T, Row>
    /// Matches rows whose column isn't in a list of values: `WHERE column NOT IN ($1, $2, …)`.
    func WHERE<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, NOT_IN values: [U]) -> TypedWhereSQLQuery<T, Row>
    /// Matches rows whose column matches a pattern: `WHERE column LIKE $1`.
    ///
    /// ```swift
    /// .WHERE(\.email, LIKE: "%@example.com")
    /// ```
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T,U>>, LIKE value: String) -> TypedWhereSQLQuery<T, Row>
    /// Matches rows whose column doesn't match a pattern: `WHERE column NOT LIKE $1`.
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T,U>>, NOT_LIKE value: String) -> TypedWhereSQLQuery<T, Row>
    /// Matches rows whose column is within an inclusive range: `WHERE column BETWEEN $1 AND $2`.
    ///
    /// ```swift
    /// .WHERE(\.age, BETWEEN: 18, AND: 65)
    /// ```
    func WHERE<U: Comparable & Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, BETWEEN low: U, AND high: U) -> TypedWhereSQLQuery<T, Row>
    /// Filters rows with a comparison on a column of the main table.
    ///
    /// ```swift
    /// .WHERE(\.age >= 18)   // WHERE age >= $1
    /// ```
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T, Row>
    /// Filters rows with a comparison on a nullable column of the main table.
    ///
    /// To match `NULL`, use `.WHERE(\.column).IS_NULL` instead.
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y?>) -> TypedWhereSQLQuery<T, Row>
    /// Starts a `NULL` test on a column. Follow it with `IS_NULL` or `IS_NOT_NULL`.
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T,U>>) -> PartialTypedWhereSQLQuery<T, U, Row>
    /// Filters rows with a condition written as SQL.
    ///
    /// If the string has the form `column <operator> value`, where the operator is `=`, `!=`, `<`, `<=`, `>` or `>=` with a space on each side, the value is bound as a parameter. Otherwise the string is inserted verbatim.
    ///
    /// > Warning: The string is split at the first spaced comparison operator, so compound conditions containing one aren't supported. Verbatim strings aren't parameterized, so never build them from user input.
    func WHERE(_ rawString: String) -> TypedWhereSQLQuery<T, Row>
    /// Filters rows with a comparison on a table-qualified column, which can belong to any table in the query.
    ///
    /// ```swift
    /// .WHERE(users.age >= 18)   // WHERE users.age >= $1
    /// ```
    func WHERE<U: Table, Y: Encodable>(_ predicate: TableColumnPredicate<U, Y>) -> TypedWhereSQLQuery<T, Row>
    /// Filters rows with a comparison on a column of another table, given as a fully typed key path.
    ///
    /// ```swift
    /// .WHERE(\UsersDepartmentsTable.user_id == id)   // WHERE users_departments.user_id = $1
    /// ```
    func WHERE<U: Table, Y>(_ predicate: SQLPredicate<U, Y>) -> TypedWhereSQLQuery<T, Row>
}


public extension WHEREableQuery {
    
    /// Matches rows whose column is in a list of values: `WHERE column IN ($1, $2, …)`.
    ///
    /// ```swift
    /// .WHERE(\.name, IN: ["Ada", "Grace"])   // WHERE name IN ($1, $2)
    /// ```
    func WHERE<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, IN values: [U]) -> TypedWhereSQLQuery<T, Row> {
        var pNumber = parameterNumber()
        func nextParamSign() -> String {
            pNumber += 1
            return "$\(pNumber)"
        }
        return TypedWhereSQLQuery(for: table, query: query + " WHERE" + " \(table[keyPath: kp].name)" + " IN (\(values.map{_ in "\(nextParamSign())"}.joined(separator: ", ")))", parameters: parameters + values)
    }
    
    /// Matches rows whose column is among a subquery's results: `WHERE column IN (SELECT …)`.
    ///
    /// The subquery must select a single column of the same type. Its placeholders are renumbered to follow this query's placeholders.
    ///
    /// ```swift
    /// .WHERE(\.id, IN: SQL.SELECT(\.author_id).FROM(posts).WHERE(\.likes > 1000))
    /// // WHERE id IN (SELECT author_id FROM posts WHERE likes > $1)
    /// ```
    func WHERE<U, Q: TableSQLQuery>(_ kp: KeyPath<T, TableColumn<T, U>>, IN subquery: Q) -> TypedWhereSQLQuery<T, Row> where Q.Row == U {
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(table[keyPath: kp].name) IN (\(embedded(subquery)))", parameters: parameters + subquery.parameters)
    }

    /// Matches rows whose nullable column is among a subquery's results: `WHERE column IN (SELECT …)`.
    ///
    /// The subquery must select a single column of the non-optional type.
    func WHERE<U, Q: TableSQLQuery>(_ kp: KeyPath<T, TableColumn<T, U?>>, IN subquery: Q) -> TypedWhereSQLQuery<T, Row> where Q.Row == U {
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(table[keyPath: kp].name) IN (\(embedded(subquery)))", parameters: parameters + subquery.parameters)
    }

    /// WHERE `table.column` IN (subquery) on a column of any table (e.g. a JOINed one).
    func WHERE<U: Table, Y, Q: TableSQLQuery>(_ column: TableColumn<U, Y>, IN subquery: Q) -> TypedWhereSQLQuery<T, Row> where Q.Row == Y {
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(column.toString()) IN (\(embedded(subquery)))", parameters: parameters + subquery.parameters)
    }
    
    /// Matches rows whose column matches a pattern: `WHERE column LIKE $1`.
    ///
    /// ```swift
    /// .WHERE(\.email, LIKE: "%@example.com")
    /// ```
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T, U>>, LIKE value: String) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(table[keyPath: kp].name) like \(nextDollarSign())", parameters: parameters + [value])
    }

    /// Matches rows whose column isn't in a list of values: `WHERE column NOT IN ($1, $2, …)`.
    func WHERE<U: Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, NOT_IN values: [U]) -> TypedWhereSQLQuery<T, Row> {
        var pNumber = parameterNumber()
        func nextParamSign() -> String {
            pNumber += 1
            return "$\(pNumber)"
        }
        return TypedWhereSQLQuery(for: table, query: query + " WHERE" + " \(table[keyPath: kp].name)" + " NOT IN (\(values.map{_ in "\(nextParamSign())"}.joined(separator: ", ")))", parameters: parameters + values)
    }

    /// Matches rows whose column doesn't match a pattern: `WHERE column NOT LIKE $1`.
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T, U>>, NOT_LIKE value: String) -> TypedWhereSQLQuery<T, Row> {
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(table[keyPath: kp].name) NOT LIKE \(nextDollarSign())", parameters: parameters + [value])
    }

    /// Matches rows whose column is within an inclusive range: `WHERE column BETWEEN $1 AND $2`.
    ///
    /// ```swift
    /// .WHERE(\.age, BETWEEN: 18, AND: 65)
    /// ```
    func WHERE<U: Comparable & Encodable>(_ kp: KeyPath<T, TableColumn<T,U>>, BETWEEN low: U, AND high: U) -> TypedWhereSQLQuery<T, Row> {
        let p1 = nextDollarSign()
        let p2 = "$\(parameterNumber() + 2)"
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(table[keyPath: kp].name) BETWEEN \(p1) AND \(p2)", parameters: parameters + [low, high])
    }

    /// Filters rows with a comparison on a column of the main table.
    ///
    /// ```swift
    /// .WHERE(\.age >= 18)   // WHERE age >= $1
    /// ```
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y>) -> TypedWhereSQLQuery<T, Row> {
        let q = query + " WHERE \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table,
                                  query: q,
                                  parameters: parameters + [predicate.right])
    }
    
    /// Filters rows with a comparison on a nullable column of the main table.
    ///
    /// To match `NULL`, use `.WHERE(\.column).IS_NULL` instead.
    func WHERE<Y>(_ predicate: SQLPredicate<T, Y?>) -> TypedWhereSQLQuery<T, Row> {
        let q = query + " WHERE \(table[keyPath: predicate.left].name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters:  parameters + [predicate.right!])
    }
    
    /// Starts a `NULL` test on a column. Follow it with `IS_NULL` or `IS_NOT_NULL`.
    ///
    /// ```swift
    /// .WHERE(\.bio).IS_NOT_NULL   // WHERE bio IS NOT NULL
    /// ```
    func WHERE<U>(_ kp: KeyPath<T, TableColumn<T, U>>) -> PartialTypedWhereSQLQuery<T, U, Row> {
        return PartialTypedWhereSQLQuery(for: table, query: query, parameters: parameters, keypath: kp)
    }
    
    /// Filters rows with a comparison on a table-qualified column, which can belong to any table in the query.
    ///
    /// ```swift
    /// .WHERE(users.age >= 18)   // WHERE users.age >= $1
    /// ```
    func WHERE<U: Table, Y: Encodable>(_ predicate: TableColumnPredicate<U, Y>) -> TypedWhereSQLQuery<T, Row> {
        let q = query + " WHERE \(predicate.column.tableName).\(predicate.column.name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }
    
    /// Filters rows with a comparison on a column of another table, given as a fully typed key path.
    ///
    /// ```swift
    /// .WHERE(\UsersDepartmentsTable.user_id == id)   // WHERE users_departments.user_id = $1
    /// ```
    func WHERE<U: Table, Y>(_ predicate: SQLPredicate<U, Y>) -> TypedWhereSQLQuery<T, Row> {
        let otherTable = U()
        let column = otherTable[keyPath: predicate.left]
        let q = query + " WHERE \(column.tableName).\(column.name) \(predicate.sign) \(nextDollarSign())"
        return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [predicate.right])
    }
    
    /// Filters rows with a condition written as SQL.
    ///
    /// If the string has the form `column <operator> value`, where the operator is `=`, `!=`, `<`, `<=`, `>` or `>=` with a space on each side, the value is bound as a parameter. Otherwise the string is inserted verbatim.
    ///
    /// > Warning: The string is split at the first spaced comparison operator, so compound conditions containing one aren't supported. Verbatim strings aren't parameterized, so never build them from user input.
    func WHERE(_ rawString: String) -> TypedWhereSQLQuery<T, Row> {
        let operators = [">=", "<=", "!=", ">", "<", "="]
        for op in operators {
            let parts = rawString.components(separatedBy: " \(op) ")
            if parts.count == 2 {
                let column = parts[0].trimmingCharacters(in: .whitespaces)
                let rawValue = parts[1].trimmingCharacters(in: .whitespaces)
                let value: any Encodable
                if let intValue = Int(rawValue) {
                    value = intValue
                } else if let doubleValue = Double(rawValue) {
                    value = doubleValue
                } else if (rawValue.hasPrefix("'") && rawValue.hasSuffix("'"))
                            || (rawValue.hasPrefix("\"") && rawValue.hasSuffix("\"")) {
                    value = String(rawValue.dropFirst().dropLast())
                } else {
                    value = rawValue
                }
                let q = query + " WHERE \(column) \(op) \(nextDollarSign())"
                return TypedWhereSQLQuery(for: table, query: q, parameters: parameters + [value])
            }
        }
//        // Fallback: append raw string as-is with no parameters
        return TypedWhereSQLQuery(for: table, query: query + " WHERE \(rawString)", parameters: parameters)
    }
}

