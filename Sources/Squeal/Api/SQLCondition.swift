//
//  SQLCondition.swift
//  Squeal
//

/// A condition for `WHERE`, `AND` and `OR` that doesn't depend on the query's main table.
///
/// Comparisons of table-qualified columns (``TableColumnPredicate``, ``JOINPredicate``),
/// ``EXISTS``, ``NOT_EXISTS``, ``SQLExpr`` and date comparisons with ``NOW`` conform.
/// `WHERE`, `AND` and `OR` take any of them through a single overload, which keeps queries
/// fast to type-check.
///
/// Only Squeal's own types conform. Don't conform your own types.
public protocol SQLCondition {}

/// How a ``SQLCondition`` renders.
protocol RenderableSQLCondition: SQLCondition {
    /// The condition's SQL and parameters when appended to `fragment`, whose main table is `table`.
    func render<Q: Table>(after fragment: some SQLFragment, mainTable table: Q.Type) -> (sql: String, parameters: [(any Encodable)?])
}

extension SQLFragment {
    /// The query with `keyword condition` appended.
    func appending<Q: Table>(_ keyword: String, _ condition: some SQLCondition, mainTable: Q.Type) -> (query: String, parameters: [(any Encodable)?]) {
        guard let condition = condition as? any RenderableSQLCondition else {
            preconditionFailure("\(type(of: condition)) conforms to SQLCondition, which only Squeal's own types may do.")
        }
        let (sql, newParameters) = condition.render(after: self, mainTable: mainTable)
        return (query + " \(keyword) \(sql)", parameters + newParameters)
    }
}

extension SQLExpr: RenderableSQLCondition {
    func render<Q: Table>(after fragment: some SQLFragment, mainTable table: Q.Type) -> (sql: String, parameters: [(any Encodable)?]) {
        let (fragments, parameters) = renderSQLValues([self], parameterOffset: fragment.parameterNumber())
        return (fragments[0], parameters)
    }
}

extension EXISTS: RenderableSQLCondition {
    func render<Q: Table>(after fragment: some SQLFragment, mainTable table: Q.Type) -> (sql: String, parameters: [(any Encodable)?]) {
        return (sql(after: fragment), subquery.parameters)
    }
}

extension NOT_EXISTS: RenderableSQLCondition {
    func render<Q: Table>(after fragment: some SQLFragment, mainTable table: Q.Type) -> (sql: String, parameters: [(any Encodable)?]) {
        return (sql(after: fragment), subquery.parameters)
    }
}

extension TableColumnPredicate: RenderableSQLCondition {
    func render<Q: Table>(after fragment: some SQLFragment, mainTable table: Q.Type) -> (sql: String, parameters: [(any Encodable)?]) {
        return ("\(column.toString()) \(sign) \(fragment.nextDollarSign())", [right])
    }
}

extension JOINPredicate: RenderableSQLCondition {
    func render<Q: Table>(after fragment: some SQLFragment, mainTable table: Q.Type) -> (sql: String, parameters: [(any Encodable)?]) {
        return (sql, [])
    }
}

/// A key-path comparison on another table than the query's, such as `\UsersDepartmentsTable.user_id == id`.
extension SQLPredicate: RenderableSQLCondition {
    func render<Q: Table>(after fragment: some SQLFragment, mainTable table: Q.Type) -> (sql: String, parameters: [(any Encodable)?]) {
        let column = T()[keyPath: left]
        let (fragments, parameters) = renderSQLValues([right], parameterOffset: fragment.parameterNumber())
        return ("\(column.tableName).\(column.name) \(sign) \(fragments[0])", parameters)
    }
}

extension NOWPredicate: RenderableSQLCondition {
    func render<Q: Table>(after fragment: some SQLFragment, mainTable table: Q.Type) -> (sql: String, parameters: [(any Encodable)?]) {
        let (fragments, parameters) = renderSQLValues([expression], parameterOffset: fragment.parameterNumber())
        return (fragments[0], parameters)
    }
}
