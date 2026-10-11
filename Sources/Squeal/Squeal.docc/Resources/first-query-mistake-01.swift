let typo = SQL
    .SELECT(users.id, users.nmae)
    .FROM(users)
// error: value of type 'UserTable' has no member 'nmae'
