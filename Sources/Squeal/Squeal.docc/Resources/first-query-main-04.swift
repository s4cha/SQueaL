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

let page = 2
let usersPage = SELECT(\.id, \.name, \.email)
    .FROM(users)
    .ORDER_BY(\.name, .ASC)
    .LIMIT(20)
    .OFFSET(page * 20)
// SELECT id, name, email FROM users ORDER BY name ASC LIMIT $1 OFFSET $2
