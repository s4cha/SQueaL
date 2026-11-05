import Squeal

let allUsers = SELECT(*)
    .FROM(users)
// SELECT * FROM users

let userList = SELECT(\.id, \.name, \.email)
    .FROM(users)
// SELECT id, name, email FROM users
