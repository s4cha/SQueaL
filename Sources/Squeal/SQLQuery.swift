//
//  SQLQuery.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


/// SQL text plus the values bound to its placeholders, complete or still being built.
///
/// Every step of a query conforms. Only the steps that form a complete statement also conform
/// to ``SQLQuery``, which is what you can run. For example, `SQL.DELETE(FROM: posts)` is a
/// fragment: it becomes a query once you add `WHERE`.
public protocol SQLFragment: CustomStringConvertible {
    /// The SQL text, with `$1`, `$2`, … placeholders where values go.
    var query: String { get }
    /// The values for the placeholders in ``query``, in order. A `nil` value is bound as `NULL`.
    var parameters: [(any Encodable)?] { get }
}

/// A complete query that you can run: SQL text plus the values bound to its placeholders.
///
/// Send ``SQLFragment/query`` and ``SQLFragment/parameters`` to the database together. The
/// `description` inlines the parameters for logging, and you should never execute it. See
/// <doc:ParametersAndSafety>.
public protocol SQLQuery: SQLFragment {}
