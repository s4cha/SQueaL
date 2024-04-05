# Squeal
Type Safe SQL in Swift

*Squeal is th sound you make when you realize there's a typo in your SQL statement.*

## Demo time 🍿
Raw SQL
```sql
let query = """
    SELECT email FROM users
    WHERE id = 1
    AND name = 'jack' 
    LIMIT 1
"""
```
Using Squeal
```swift
let query = ""
    .SELECT(\.email, FROM: users)
    .WHERE(\.id == 1)
    .AND(\.name == "jack")
    .LIMIT(1)
```
hint: `users` is a `Table` object that represents the `users` table in the database schema.


## Disclaimer
This is early  
Use at your own risk  
Only supports Postgres syntax at the moment

## Why
- ORMS have a lot of issues (see below), mainly:
    - Need to learn an other pseudo language 
    - Complex 
    - Hides what's really going on under the hood
    - Performace issues
  

- The alternative, writing Pure SQL comes with major drawbacks:
  - No more type safety
  - No IDE support


## What if we could have the best of both worlds?


# Requirements
- Should not need to learn a new language, should **READ like SQL**
- Be **Type-safe**: use Swift type system to ensure that queries are correct at compile time
- Be debuggable: allow for easy debugging of queries
- Be maintainable: allow for easy maintenance of queries
- Changing table representation should break all related queries
- Changing a column name should break all related queries
- Database schema representation should be in one place only
- As **performant** as SQL, Because it IS SQL.
- Flexible Can always Escape hatch to raw SQL if needed.
- Table names / column neame refactoring should prevent sql issues.

# How
- By leveraging incredible Swift's type system to enforce correctness at compile time
- By defining the database schema in one place only


## What
- Swift Api mimicking SQL almost one to one.
- Strongly typed Api that forces you to use the correct syntax.
- Strongly typed Api that forces you to use the correct types.
- SQLQueries are `CustomStringConvertible` and should be used as strings.
- A `DatabaseSchema` file where the database representation resides


## ORM issues great reads

[The Vietnam of Computer Science](https://web.archive.org/web/20220823105749/http://blogs.tedneward.com/post/the-vietnam-of-computer-science/)  
[Object-Relational Mapping is the Vietnam of Computer Science](https://blog.codinghorror.com/object-relational-mapping-is-the-vietnam-of-computer-science/)  
[ORM is an anti-pattern](https://seldo.com/posts/orm_is_an_antipattern)  
[In defence of SQL](https://seldo.com/posts/in_defence_of_sql)
