import Squeal

let allUsers = SQL
    .SELECT(*)
    .FROM(users)
// SELECT * FROM users

let userList = SQL
    .SELECT(\.id, \.name, \.email)
    .FROM(users)
// SELECT id, name, email FROM users

let adults = SQL
    .SELECT(\.id, \.name, \.email)
    .FROM(users)
    .WHERE(\.age >= 18)
    .AND(\.name == "Ada")
// SELECT id, name, email FROM users WHERE age >= $1 AND name = $2
