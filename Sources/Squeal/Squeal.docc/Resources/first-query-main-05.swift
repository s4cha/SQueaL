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

let page = 2
let usersPage = SQL
    .SELECT(\.id, \.name, \.email)
    .FROM(users)
    .ORDER_BY(\.name, .ASC)
    .LIMIT(20)
    .OFFSET(page * 20)
// SELECT id, name, email FROM users ORDER BY name ASC LIMIT 20 OFFSET 40

print(adults.query)
// SELECT id, name, email FROM users WHERE age >= $1 AND name = $2
