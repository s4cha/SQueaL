# SQueaL
Type Safe SQL in Swift

*Squeal is the sound you make when you realize there's a typo in your SQL statement.*

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


**What if we could have the best of both worlds?**

## Requirements
- Should **Read like SQL**
- Be **Type-safe**
- Should **Enforce correct SQL Syntax** with IDE autocompletion
- Usable in place of raw SQL Strings


## How
- By designing a Swift API that mimics SQL statements almost one to one
- By leveraging the incredible Swift's type system to enforce correctness at compile time
- By using Swift Type system to enforce SQL syntax 
- By using Swift's `CustomStringConvertible` protocol to generate raw SQL strings

## ORM issues great reads
[Don't use an ORM - Prime reacts](https://youtu.be/bpGvVI7NM_k?feature=shared)  
[The Vietnam of Computer Science](https://web.archive.org/web/20220823105749/http://blogs.tedneward.com/post/the-vietnam-of-computer-science/)  
[Object-Relational Mapping is the Vietnam of Computer Science](https://blog.codinghorror.com/object-relational-mapping-is-the-vietnam-of-computer-science/)  
[ORM is an anti-pattern](https://seldo.com/posts/orm_is_an_antipattern)  
[In defence of SQL](https://seldo.com/posts/in_defence_of_sql)


[//]: # (- Changing table representation should break all related queries)
[//]: # (- Changing a column name should break all related queries)
[//]: # (- Database schema representation should be in one place only)
[//]: # (- Flexible Can always Escape hatch to raw SQL if needed.)
[//]: # (- Table names / column neame refactoring should prevent sql issues.)
[//]: # (- By defining the database schema in one place only)
[//]: # (- A `DatabaseSchema` file where the database representation resides)
