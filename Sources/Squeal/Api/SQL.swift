//
//  SQL.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 11/04/2024.
//

import Foundation

/// The statements that start a query, as static methods.
///
/// Start a query with `SELECT`, `INSERT`, `UPDATE` or `DELETE_FROM`, then chain clauses in the
/// same order you'd write them in SQL:
///
/// ```swift
/// let query = SELECT(\.id, \.name)
///     .FROM(users)
///     .WHERE(\.age >= 18)
///     .LIMIT(10)
/// // SELECT id, name FROM users WHERE age >= $1 LIMIT $2
/// ```
///
/// Each statement is a global function, and also a static method of `SQL`: `SQL.SELECT(…)`
/// builds the same query as `SELECT(…)`. `SQL` is a namespace and is never instantiated.
public class SQL {
    
}

/// A query entry point with the table type fixed up front.
///
/// `TSQL<UserTable>` works like ``SQL``, except that key paths resolve against `UserTable`
/// before you reach `FROM`:
///
/// ```swift
/// TSQL<UserTable>.SELECT(\.id, \.name).FROM(users)
/// // SELECT id, name FROM users
/// ```
public class TSQL<T: Table> {
    
}
