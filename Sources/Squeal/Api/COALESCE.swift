//
//  COALESCE.swift
//  Squeal
//

/// A value, or a column's current value when it's `nil`: `COALESCE($n, table.column)`.
///
/// Use it in `UPDATE … SET` for partial updates, where `nil` means "keep what's there":
///
/// ```swift
/// SQL.UPDATE(studies, SET:
///         (\.name, COALESCE(update.name, studies.name)),
///         (\.starting_cash, COALESCE(update.startingCash, studies.starting_cash)))
///     .WHERE(\.id == id)
/// // UPDATE studies SET name = COALESCE($1, studies.name),
/// //     starting_cash = COALESCE($2, studies.starting_cash) WHERE id = $3
/// ```
///
/// The value must have the column's type, so `COALESCE(update.startingCash, studies.name)`
/// doesn't compile. The value is bound as a parameter, like every other value.
///
/// Pass the column as a table column (`studies.name`), not a key path: a `SET` pair can't
/// tell a key path which table it belongs to.
///
/// > Note: `COALESCE` reads the column's current value, so it only makes sense in
/// > `UPDATE … SET`. In `INSERT … VALUES` the row doesn't exist yet, and Postgres rejects the
/// > column reference.
public struct COALESCE<Value>: SQLValueExpression {
    let value: (any Encodable)?
    let column: String

    /// The value, or the column's current value when `value` is `nil`.
    public init<T: Table>(_ value: Value?, _ column: TableColumn<T, Value>) where Value: Encodable {
        self.value = value
        self.column = column.toString()
    }

    var valueExpression: any SQLExpressionText {
        return SQLExpr<Any>(sql: "COALESCE(?, \(column))", parameters: [value])
    }
}

/// A value that renders as SQL with bound parameters in `INSERT … VALUES` and `UPDATE … SET`,
/// such as ``COALESCE``.
protocol SQLValueExpression {
    var valueExpression: any SQLExpressionText { get }
}
