//
//  SQLQuery.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


/// A built query: SQL text plus the values bound to its placeholders.
///
/// Send ``query`` and ``parameters`` to the database together. The `description` inlines the
/// parameters for logging, and you should never execute it. See <doc:ParametersAndSafety>.
public protocol SQLQuery: CustomStringConvertible {
    /// The SQL text, with `$1`, `$2`, … placeholders where values go.
    var query: String { get }
    /// The values for the placeholders in ``query``, in order. A `nil` value is bound as `NULL`.
    var parameters: [(any Encodable)?] { get }
}
