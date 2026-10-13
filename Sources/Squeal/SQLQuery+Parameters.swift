//
//  SQLQuery+Parameters.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 11/04/2024.
//

import Foundation


public extension SQLFragment {

    /// The placeholder for the next parameter added to this query, such as `$3`.
    func nextDollarSign() -> String {
        return "$\(parameterNumber() + 1)"
    }

    /// The number of placeholders already in ``query``.
    func parameterNumber() -> Int {
        return query.filter { $0 == "$" }.count
    }

    /// The SQL of `subquery`, with its `$n` placeholders shifted so they follow this query's parameters.
    /// Append `subquery.parameters` to this query's parameters alongside it.
    func embedded(_ subquery: SQLQuery) -> String {
        return shiftingParameters(of: subquery.query, by: parameterNumber())
    }
}

/// `sql` with every `$n` placeholder renumbered to `$(n + offset)`.
func shiftingParameters(of sql: String, by offset: Int) -> String {
    return sql.replacing(/\$(\d+)/) { match in "$\(Int(match.1)! + offset)" }
}
