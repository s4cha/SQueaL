let wrongOrder = SQL
    .SELECT(\.id)
    .FROM(users)
    .LIMIT(10)
    .WHERE(\.age >= 18)
// error: value of type 'TypedLimitSQLQuery<UserTable, UUID>' has no member 'WHERE'
