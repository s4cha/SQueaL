let wrongType = SQL
    .SELECT(users.id)
    .FROM(users)
    .WHERE(users.age >= "18")
// error: binary operator '>=' cannot be applied to operands of type
//        'TableColumn<UserTable, Int>' and 'String'
