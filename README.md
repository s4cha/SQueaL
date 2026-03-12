# SQueaL

[![Swift](https://img.shields.io/badge/Swift-6.2-F05138?logo=swift&logoColor=white)](https://www.swift.org)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub tag](https://img.shields.io/github/release/s4cha/Squeal.svg)](https://github.com/s4cha/Squeal/releases)

Type Safe SQL for Swift

![SQueaL demo](demo.gif)

*Squeal is the sound you make when you realize there's a typo in your SQL statement.*

## Demo time 🍿
Raw SQL
```sql
let query = """
    SELECT id, name, email 
    FROM users
    WHERE id = 1
    AND name = 'jack' 
    LIMIT 1
"""
```
Using Squeal
```swift
let query = SQL
    .SELECT(\.id, \.name, \.email)
    .FROM(users)
    .WHERE(\.id == 1)
    .AND(\.name == "jack")
    .LIMIT(1)
```
hint: `users` is a `Table` object that represents the `users` table in the database schema.


## Benefits: 
 - [X] Type safety
 - [X] Autocompletion
 - [X] Valid SQL Syntax enforcement
 - [X] Safer refactorings
 - [X] Generates a SQL string so you can escape the tool whenever needed.


## Disclaimer
 - This is early, use at your own risk
 - Only supports Postgres syntax at the moment

## Why SQueaL?

|  | Raw SQL Strings | ORM(Fluent, Structured Queries etc) | **SQueaL** |
|---|---|---|---|
| Type safety (Safe refactorings) | ❌ | ✅ | ✅ |
| Autocompletion | ❌ | ✅ | ✅ | ✅ |
| SQL syntax enforcement (clause order) | ❌ | ❌ | ✅ |
| No new DSL to learn (Learn SQL once) | ✅ | ❌ | ✅ |
| Easy to eject | ✅ | ❌ | ✅ |

**What if you could have the best of both worlds?** Type safety *and* real SQL.

- ORMS have a lot of issues (see below), mainly:
    - Need to learn an other pseudo language 
    - Complex 
    - Hides what's really going on under the hood
    - Performace issues
  

- The alternative, writing Pure SQL comes with major drawbacks:
  - No more type safety
  - No IDE support
  - Risky refactorings
  - No syntax enforcement.


**What if we could have the best of both worlds?**

## How
- By leveraging the **incredible Swift 6 type system** we can create a strongly typed DSL that **match SQL syntax almost one to one**.
- By having a strongly typed table reference we can **enforce correctness** and **simplify refactorings**.
- By using protocols we can enforce **correct SQL syntax** and have **autocompletion** only suggest valid SQL clauses.

## What: Example Queries

First define your Type safe schema like so:
```swift
@Table(schema: "users") // Name of your database table
struct Users {
    let uuid: UUID // Name of your database columns with their type.
    let id: Int
    let name: String
    let age: Int
}
```
The macro will generate the associated `UsersTable` struct.


### SELECT FROM
```swift
let users = UsersTable()
```

```swift
let query = SQL
  .SELECT(*)
  .FROM(users)
  .LIMIT(10)
```

```swift
 let query = SQL
    .SELECT(COUNT(*))
    .FROM(users)
```

```swift
 let query = SQL
    .SELECT(COUNT(*))
    .FROM(users)
```

```swift
let query = TSQL
  .SELECT(
    (\.uuid, AS: "unique_id"),
    (\.id, AS: "user_id"),
    (\.name, AS: "username"))
  .FROM(users)
```

### WHERE / AND / OR

```swift
let query = SQL
  .SELECT(\.id)
  .FROM(users)
  .WHERE(\.id < 65)
  .AND(\.name == "Jack")
  .OR(\.name == "john")
```

### INSERT
```swift
let query = SQL
  .INSERT(INTO: studies,
    columns: \.name, \.starting_cash, \.partitioning, \.prolific_study_id, \.completion_link, \.shows_results, \.allows_fractional_investing,
    VALUES: study.name, study.startingCash, study.partitioning, study.prolificStudyId, study.completionLink, study.showsResults, study.allowsFractionalInvesting)
  .RETURNING(\.id)
```

### UPDATE
```swift
let query = SQL
  .UPDATE(stocks,
    SET:
      (\.volatility, stock.volatility),
      (\.expectedReturn, stock.expectedReturn),
      (\.currentPrice, stock.currentPrice)
    )
  .WHERE(\.id == stock.id!)
```

### DELETE
```swift
let query = SQL
  .DELETE_FROM(users)
   .WHERE(\.id == 243)
```

## ORM issues great reads
[What ORMs have taught me: just learn SQL](https://wozniak.ca/blog/2014/08/03/1/index.html)  
[Don't use an ORM - Prime reacts](https://youtu.be/bpGvVI7NM_k?feature=shared)  
[The Vietnam of Computer Science](https://web.archive.org/web/20220823105749/http://blogs.tedneward.com/post/the-vietnam-of-computer-science/)  
[Object-Relational Mapping is the Vietnam of Computer Science](https://blog.codinghorror.com/object-relational-mapping-is-the-vietnam-of-computer-science/)  
[ORM is an anti-pattern](https://seldo.com/posts/orm_is_an_antipattern)  
[In defence of SQL](https://seldo.com/posts/in_defence_of_sql)

## Installation

Requires **Swift 6.0+**.

In Xcode, go to `File` > `Add Package Dependencies...` and paste:
```
https://github.com/s4cha/Squeal
```

Or add it to your `Package.swift`:
```swift
.package(url: "https://github.com/s4cha/Squeal", from: "1.0.0")
```