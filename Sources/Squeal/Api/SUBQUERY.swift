//
//  SUBQUERY.swift
//  Squeal
//

/// A subquery used as a value in a `SELECT` or `RETURNING` list: `(SELECT …)`.
///
/// The subquery must return a single column and at most one row. It usually refers to the
/// outer query's table with a column comparison, so it's evaluated for each row. For example,
/// each user's latest post title:
///
/// ```swift
/// let latestTitle = SQL
///     .SELECT(\.title)
///     .FROM(posts)
///     .WHERE(posts.author_id == users.id)
///     .ORDER_BY(\.published_at, .DESC)
///     .LIMIT(1)
///
/// SQL.SELECT(users.name, SUBQUERY(latestTitle)).FROM(users)
/// // SELECT users.name, (SELECT title FROM posts WHERE posts.author_id = users.id
/// //     ORDER BY published_at DESC LIMIT $1) FROM users
/// ```
///
/// The value is `NULL` when the subquery returns no row, so decode it as an optional.
/// The subquery's placeholders are renumbered to follow the ones before it in the query.
public struct SUBQUERY: SelectField, ParameterizedSelectField {
    let subquery: any TableSQLQuery

    /// A subquery's single value.
    public init(_ subquery: some TableSQLQuery) {
        self.subquery = subquery
    }

    /// The subquery in parentheses, with its placeholders numbered from `$1`.
    public func toString() -> String {
        return "(\(subquery.query))"
    }

    var parameters: [(any Encodable)?] { subquery.parameters }
}

/// A `SELECT` or `RETURNING` expression with bound parameters, such as ``SUBQUERY``.
///
/// `toString()` numbers its placeholders from `$1`. They're shifted when the expression is
/// placed in a query.
protocol ParameterizedSelectField: SelectField {
    var parameters: [(any Encodable)?] { get }
}

/// The SQL of a `SELECT` or `RETURNING` list, and the parameters it adds.
///
/// `parameterOffset` is the number of placeholders already in the query, so the fields'
/// placeholders follow them.
func renderSelectFields<each F: SelectField>(_ fields: repeat each F, parameterOffset: Int) -> (sql: String, parameters: [(any Encodable)?]) {
    var names = [String]()
    var parameters = [(any Encodable)?]()
    for field in repeat each fields {
        if let field = field as? any ParameterizedSelectField {
            names.append(shiftingParameters(of: field.toString(), by: parameterOffset + parameters.count))
            parameters += field.parameters
        } else {
            names.append(field.toString())
        }
    }
    return (names.joined(separator: ", "), parameters)
}
