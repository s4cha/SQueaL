# What Squeal Checks

The mistakes Squeal turns into compile errors, how it helps when your schema changes, and
what it leaves to you.

## Overview

With SQL in strings, the compiler sees only text. Every mistake, from a typo to a schema
change you forgot about, shows up when the query runs, often in production. Squeal moves
most of those mistakes to compile time while keeping the SQL you know.

This page lists what Squeal checks today, and what it doesn't.

### Mistakes caught at compile time

**A misspelled column.** Columns are properties of your table type, so a typo isn't a
column:

```swift
SQL.SELECT(users.id, users.nmae).FROM(users)
// error: value of type 'UserTable' has no member 'nmae'
```

**A column from the wrong table.** Key paths resolve against the table in `FROM`. `posts`
has a `title` column but `users` doesn't, so this doesn't compile:

```swift
SQL.SELECT(*).FROM(users).WHERE(\.title == "Hello")
```

**A value of the wrong type.** Each column carries its Swift type, so comparing `age` to a
`String` doesn't compile:

```swift
SQL.SELECT(users.id).FROM(users).WHERE(users.age >= "18")
// error: binary operator '>=' cannot be applied to operands of type
//        'TableColumn<UserTable, Int>' and 'String'
```

**Clauses in the wrong order.** Each clause returns a type that only offers the clauses SQL
allows next, so autocompletion never suggests an invalid one:

```swift
SQL.SELECT(\.id).FROM(users).LIMIT(10).WHERE(\.age >= 18)
// error: value of type 'TypedLimitSQLQuery<UserTable, UUID>' has no member 'WHERE'
```

**Comparing a non-date column with `NOW()`.** ``NOW`` only compares with `Date` and
`Date?` columns:

```swift
SQL.SELECT(\.id).FROM(posts).WHERE(\.title < NOW())
// error: cannot convert value of type 'NOW' to expected argument type 'String'
```

**A join between columns of different types.** Both sides of a join condition must have the
same type, so joining a `String` to a `UUID` doesn't compile:

```swift
SQL.SELECT(posts.title).FROM(posts).JOIN(users, ON: posts.title == users.id)
```

**A subquery of the wrong type in `IN`.** A subquery that selects one key path remembers its
column's type, and `IN` requires it to match the filtered column:

```swift
SQL.SELECT(\.id).FROM(users).WHERE(\.id, IN: SQL.SELECT(\.title).FROM(posts))
// doesn't compile: the subquery returns String, but users.id is a UUID
```

**`= NULL` instead of `IS NULL`.** In SQL, `column = NULL` is never true, a classic bug.
Squeal gives you ``PartialTypedWhereSQLQuery/IS_NULL`` and
``PartialTypedWhereSQLQuery/IS_NOT_NULL`` instead:

```swift
SQL.SELECT(\.id).FROM(users).WHERE(\.bio).IS_NULL
// SELECT id FROM users WHERE bio IS NULL
```

### When your schema changes

Your schema lives in one place, your ``Table`` definitions, and every query refers to it.
When it changes, the compiler finds the queries you need to update:

- **Renaming a column:** Rename the property, and every query that uses the old name stops
  compiling. With a hand-written table, change the column's `name:` in one place, and every
  query uses the new name.
- **Changing a column's type:** Comparisons, joins and `IN` subqueries that use the old type
  stop compiling.
- **Dropping a column:** Every query that refers to it stops compiling.
- **Renaming a table:** Change `@Table(schema:)` once.
- **Finding where a column is used:** Columns are Swift properties, so Xcode's Find and
  Rename tools work on them, rather than a text search through SQL strings.

### Safety

- **SQL injection:** Values are always sent as bound parameters and never inserted into the
  SQL text. See <doc:ParametersAndSafety>.
- **Placeholder numbering:** Squeal numbers `$1`, `$2`, … for you, and renumbers them in
  nested subqueries, so placeholders and values can't get out of step.
- **Dynamic filters:** Add conditions with `.AND(…)` as your code needs them, instead of
  concatenating strings.
- **`NULL` values:** `SquealPostgresNIO` binds `nil` optionals as `NULL`, so a missing value
  doesn't shift the parameters that follow it.

### What Squeal doesn't check yet

> Important: The values in `INSERT … VALUES` and `UPDATE … SET` aren't type-checked
> against their columns yet. These compile, and fail when Postgres runs them:
>
> ```swift
> SQL.INSERT(INTO: users, columns: \.id, \.name, VALUES: UUID())   // 2 columns, 1 value
> SQL.INSERT(INTO: users, columns: \.age, VALUES: "eighteen")       // String into an Int column
> SQL.UPDATE(users, SET: (\.age, "eighteen"))                       // same
> ```
>
> The overloads that accept ``SQLExpr``, ``RawSQL`` and subqueries take untyped values, and
> a mismatched value silently falls through to them. This also means a subquery used as a
> value isn't checked against the column it fills.

### What Squeal leaves to you

Squeal checks queries against your Swift description of the schema. It doesn't check:

- **That your description matches the database.** Squeal doesn't read your database. If
  your ``Table`` definitions and your migrations disagree, queries fail at runtime.
- **How you decode rows.** With PostgresNIO, `rows.decode((UUID, String).self)` isn't
  checked against the columns you selected.
- **That a join's other table is in the query.** A join condition must use the joined
  table, but its other column can come from any table, even one you haven't added yet.
- **SQL semantics.** Squeal doesn't add parentheses around `AND` and `OR` conditions. Group
  them yourself with an ``SQLExpr``. It lets you write `UPDATE` and `DELETE` without
  `WHERE`, just like SQL. It can't know whether a subquery used as a value returns a single
  row.
- **Escape hatches.** The text of ``RawSQL`` and ``SQLExpr`` is inserted as you write it.
  See <doc:EscapeHatches>.
