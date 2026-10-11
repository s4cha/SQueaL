import Squeal

let allUsers = SQL
    .SELECT(*)
    .FROM(users)
// SELECT * FROM users

let userList = SQL
    .SELECT(\.id, \.name, \.email)
    .FROM(users)
// SELECT id, name, email FROM users
