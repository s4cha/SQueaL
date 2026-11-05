import Squeal

let allUsers = SELECT(*)
    .FROM(users)
// SELECT * FROM users

let userList = SELECT(\.id, \.name, \.email)
    .FROM(users)
// SELECT id, name, email FROM users

let adults = SELECT(\.id, \.name, \.email)
    .FROM(users)
    .WHERE(\.age >= 18)
    .AND(\.name == "Ada")
// SELECT id, name, email FROM users WHERE age >= $1 AND name = $2
